VERSION = "1.0.0"

local micro = import("micro")
local Config = import("micro/config")
local Buffer = import("micro/buffer")
local Util = import("micro/util")
local Strings = import("strings")

local RTCHXTemplates = Config.NewRTFiletype()

local BufPlaceholders = {}
-- Active placeholder for every buffer
-- BufPlaceholders[buf.AbsPath] = {
--   Id = Template name,
--   indices = {1,2,3, ...},
--   map = {{x1, y1}, {x2, y2}, {x3, y3}},
--   currIdx = 1
-- }

function init()
  Config.MakeCommand("CHXInsTemp", CHXInsTemp, Config.NoComplete)
  Config.MakeCommand("CHXNextPH", CHXNextPH, Config.NoComplete)
  Config.MakeCommand("CHXListTemplates", CHXListTemplates, Config.NoComplete)

  Config.TryBindKey("Alt-C", "lua:CHXTemplates.CHXInsTemp", false)
  Config.TryBindKey("Alt-N", "lua:CHXTemplates.CHXNextPH", false)
  Config.TryBindKey("Shift-F1", "lua:CHXTemplates.CHXListTemplates", false)

  Config.AddRuntimeFile("CHXTemplates", Config.RTHelp, "CHXTemplates.md")
  Config.AddRuntimeFilesFromDirectory("CHXTemplates", RTCHXTemplates,
    "Templates", "*.lua")
end

local function loadTemplatesFile(filetype)
-- Load the template file of the current filetype
-- Returns it as a map
  if (not filetype) or (filetype == "") or (filetype == "unknown") then
    filetype = "CHXText"
  end

  local TemplateFile = Config.ReadRuntimeFile(RTCHXTemplates, filetype)
  if (not TemplateFile) or (TemplateFile == "") then
    micro.InfoBar():Error("No template file for \"" .. filetype .. "\" files.")
    return nil
  end

  local chunk, err = loadstring(TemplateFile)
  if err then
    micro.InfoBar():Error("Error in \"" .. filetype .. ".lua\" file : " .. err)
    return nil
  end

  if chunk then
    local ok, res = pcall(chunk)
    if ok and type(res) == "table" then
      return res
    else
      micro.InfoBar():Error("Wrong return type(" .. type(res)
        .. ") from \"" .. filetype .. ".lua\": " .. res)
      return nil
    end
  end
  return nil
end

local function getKeyword(bp)
-- Get keyword from cursor position or the word at left.
-- Selects and returns the keyword found or `false` if none
  local c = bp.Cursor

  local keyword = Util.String(c:GetSelection(c:SelectWord()))
  if keyword:match("%S+") then return keyword end
  if (c.X <= 0) then
    micro.InfoBar():Error("No keyword found")
    return false
  end

  c:Left()
  keyword = Util.String(c:GetSelection(c:SelectWord()))
  if keyword:match("%S+") then return keyword end

  c:ResetSelection()
  c:Right()
  micro.InfoBar():Error("No keyword found")
  return false
end

local function parseTemplate(rawTemplate, startX, startY, indent)
-- Parses template text, adds indentation and gets placeholder positions
-- Returns an indented clean template and a placeholder position map
  local indentTemplate = rawTemplate:gsub("\n", "\n" .. indent)
  local placeholders = {}
  local defaultTexts = {}
  local cleanLines = {}

  local currY = startY
  for currLine in string.gmatch(indentTemplate .. "\n", "(.-)\r?\n") do
    local currX = 1
    local cleanLine = ""

    for matchStart, fullMatch, numStr, hasColon, textStr
    in currLine:gmatch("()({{(%d+)(:?)(.-)}})") do
      local matchEnd = matchStart + Util.CharacterCountInString(fullMatch) - 1
      cleanLine = cleanLine .. currLine:sub(currX, matchStart - 1)

      -- Set default placeholder text
      local phIndex = tonumber(numStr)
      local phDefault = hasColon == ":" and textStr or ""
      if not defaultTexts[phIndex] and phDefault ~= "" then
        defaultTexts[phIndex] = phDefault
      end

      -- Insert default text at placeholder
      -- Maybe we prefer at the start of the default text and select first word
      -- local phActualX = Util.CharacterCountInString(cleanLine)
      local currentDefault = defaultTexts[phIndex] or ""
      cleanLine = cleanLine .. currentDefault
      -- Maybe we prefer at the end of the default text
      local phActualX = Util.CharacterCountInString(cleanLine)

      -- Store placeholder
      if not placeholders[phIndex] then
        placeholders[phIndex] = {}
      end
      table.insert(placeholders[phIndex],
        {
          x = (currY == startY) and (phActualX + startX) or phActualX,
          y = currY,
        }
      )

      currX = matchEnd + 1
    end -- for matchStart, fullMatch, numStr, hasColon, textStr

    cleanLine = cleanLine .. currLine:sub(currX)
    table.insert(cleanLines, cleanLine)
    currY = currY + 1
  end -- for currLine

  return table.concat(cleanLines, "\n"), placeholders
end

local function phCursors(bp, cursorlist)
-- Spawns multiple cursors
  if not cursorlist or #cursorlist == 0 then return end

  bp:RemoveAllMultiCursors()
  bp.Cursor.X = cursorlist[1].x
  bp.Cursor.Y = cursorlist[1].y
  -- bp.Cursor:SelectWord()

  for i = 2, #cursorlist do
    local occ = cursorlist[i]
    local loc = Buffer.Loc(occ.x, occ.y)
    aCursor = bp:SpawnCursorAtLoc(loc)
    -- aCursor:SelectWord()
  end

  bp.Buf:RelocateCursors()
  bp:Relocate()
end

function CHXInsTemp(bp)
  local buf = bp.Buf
  local c = bp.Cursor

  local filetype = buf:FileType()
  local templates = loadTemplatesFile(filetype)
  if not templates then return false end
  local keyword = ""

  -- Try selected text as keyword first
  local templateText = nil
  if c:HasSelection() then
    keyword = Util.String(c:GetSelection())
    templateText = templates[keyword]
  end

  -- If not try whole word
  if not templateText then
    keyword = getKeyword(bp)
    if not keyword then return false end

    templateText = templates[keyword]
    if not templateText then
      micro.InfoBar():Error("No template for \"" .. keyword .. "\"")
      c:ResetSelection()
      return false
    end
  end

  -- Changing internal tabs with buffer tab configuration
  if buf.Settings["tabstospaces"] then
    templateText = templateText:gsub("\t",
      buf:IndentString(tonumber(buf.Settings["tabsize"]) or 4))
  end

  -- Second space in regex is a non-breakable space (0xA0)
  -- FIXED: If we remove keyword getting current line we can have the next case:
  --    [indent]keyword[spaces](and opcionally more text)
  -- So, when removing keyword, indent is [indent][spaces]
  if not c:HasSelection() then
    -- It must not happend... just to assure that keyword is selected
    micro.InfoBar():Error("¿Where is my selected keyword?")
    return false
  end
  local indent = buf:Line(c.CurSelection[1].Y):match("^([  \t]*)") or ""

  c:DeleteSelection()
  c:ResetSelection()
  local startX = c.X
  local startY = c.Y

  local cleanText, phMap = parseTemplate(templateText, startX, startY, indent)

  buf:Insert(Buffer.Loc(startX, startY), cleanText)

  -- Sorting and updating buffer placeholders
  local sortedIndices = {}
  local hasPlaceholders = false
  for idx, _ in pairs(phMap) do
    table.insert(sortedIndices, idx)
    hasPlaceholders = true
  end
  table.sort(sortedIndices)

  if not hasPlaceholders then
    BufPlaceholders[buf.AbsPath] = nil
    micro.InfoBar():Message("Template inserted: " .. keyword)
    return true
  end;

  BufPlaceholders[buf.AbsPath] = {
    Id = keyword,
    indices = sortedIndices,
    map = phMap,
    currIdx = #sortedIndices, -- CHXNextPH will jump to first placeholder
  }

  CHXNextPH(bp)
  return true
end

function CHXNextPH(bp)
  local phList = BufPlaceholders[bp.Buf.AbsPath]
  if not phList then
    micro.InfoBar():Error("There are not placeholders.")
    return false
  end

  phList.currIdx = phList.currIdx + 1
  if phList.currIdx > #phList.indices then
    phList.currIdx = 1
  end;

  phCursors(bp, phList.map[phList.indices[phList.currIdx]])

  micro.InfoBar():Message("Placeholder " .. phList.currIdx .. "/" ..
    #phList.indices .. " of \"" .. phList.Id .. "\" template.")
end

function onBeforeTextEvent(sbuf, ev)
  local phList = BufPlaceholders[sbuf.AbsPath]
  if not phList then return true end

  for deltaIdx = #ev.Deltas, 1, -1 do
    local delta = -ev.Deltas[deltaIdx]

    for _, phIdx in ipairs(phList.indices) do
      local curPositions = phList.map[phIdx]
      for i, curPos in ipairs(curPositions) do

        if ev.EventType <= 0 then -- TextEventRemove (-1) or TextEventReplace (0)
          if (curPos.y >= delta.End.Y) then
          -- Deletion is before cursor position
            curPos.y = curPos.y + delta.Start.Y - delta.End.Y
            if (curPos.y == delta.End.Y) and (curPos.x >= delta.End.X) then
            -- End at the same line
              curPos.x = curPos.x + delta.Start.X - delta.End.X
            end

          elseif (curPos.y > delta.Start.Y)
          or ((curPos.y == delta.Start.Y) and (curPos.x >= delta.Start.X)) then
          -- Deletion Start is before cursor position, but Deletion End is after.
            curPos.x = delta.Start.X
            curPos.y = delta.Start.Y
          end
        end

        if (ev.EventType >= 0) -- TextEventInsert (1) or TextEventReplace (0)
        and ((curPos.y > delta.Start.Y) -- and Before cursor
        or ((curPos.y == delta.Start.Y) and (curPos.x >= delta.Start.X))) then
          local str = Util.String(delta.Text)
          local dX, dY = 0, Strings.Count(str, "\n")

          if (curPos.y == delta.Start.Y) then
            local lastLinePos = Strings.LastIndex(str, "\n")
            if lastLinePos == -1 then
              dX = Util.CharacterCountInString(str)
            else
              dX = Util.CharacterCountInString(str:sub(lastLinePos + 2, -1))
            end
          end

          curPos.x = curPos.x + dX
          curPos.y = curPos.y + dY
        end -- if ev.EventType >= 0

        curPositions[i] = curPos
      end -- for i, curPos
    end -- for _, phIdx
  end -- for deltaIdx

  return true
end

function CHXListTemplates(bp)
  local filetype = bp.Buf:FileType()
  local templates = loadTemplatesFile(filetype)
  if not templates then return true end

  local lines = {}
  table.insert(lines, "======== Templates for: " .. filetype .. " ========")
--  table.insert(lines, "")

  -- Getting biggest key size
  local longestKey = 0
  for k, v in pairs(templates) do
    if (v) and (v ~= "") then
      local n = Util.CharacterCountInString(k)
      if n > longestKey then
        longestKey = n
      end
    end
  end

  for k, v in pairs(templates) do
    if (not v) or (v == "") then
        table.insert(lines, "")
        table.insert(lines, "---- " .. k .. " ----")
--        table.insert(lines, "")
    else
      local firstLine = v:gsub("%s+", " ")
      firstLine = firstLine:gsub("{{(%d+)[^}]*}}", "$%1")
      firstLine = string.format("%-" .. longestKey .."s-> %s", k, firstLine)
      firstLine = string.sub(firstLine, 1, bp:GetView().Width)
      table.insert(lines, firstLine)
    end
  end

  local content = table.concat(lines, "\n")

  -- Crear un nuevo búfer en memoria con el contenido
  local newBuf = Buffer.NewBuffer(content, filetype .. " templates")

  -- newBuf.Type = Buffer.BTInfo (= 5, not a Buftype) doesn't work
  newBuf.Type.Kind = 5
  newBuf.Type.Readonly = true
  newBuf.Type.Scratch = true
  newBuf.Type.Syntax = true

  -- TODO: Select between vertical or horizontal panel
  local newBP = bp:HSplitBuf(newBuf)
  newBuf:SetOption("softwrap", "false")

  micro.InfoBar():Message("Templates for \"" .. filetype .. "\"")
  return true
end
