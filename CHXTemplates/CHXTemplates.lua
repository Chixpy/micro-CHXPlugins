VERSION = "1.1.0"

local micro = import("micro")
local Config = import("micro/config")
local Buffer = import("micro/buffer")
local Util = import("micro/util")
local Strings = import("strings")
local FilePath = import("filepath")

local RTCHXTypeTemplates = Config.NewRTFiletype()
local RTCHXGlobalTemplates = Config.NewRTFiletype()

local BufPlaceholders = {}
-- Active placeholder for every buffer
-- BufPlaceholders[buf.AbsPath] = {
--   Id = Template name,
--   indices = {1,2,3, ...},
--   map = {{x1, y1}, {x2, y2}, {x3, y3}},
--   currIdx = 1
-- }

function init()
  Config.MakeCommand("CHXTypeTemplate", CHXTypeTemplate, Config.NoComplete)
  Config.MakeCommand("CHXGlobalTemplate", CHXGlobalTemplate, Config.NoComplete)
  Config.MakeCommand("CHXNextPH", CHXNextPH, Config.NoComplete)
  Config.MakeCommand("CHXListTypeTemplates", CHXListTypeTemplates,
    Config.NoComplete)
  Config.MakeCommand("CHXListGlobalTemplates", CHXListTypeTemplates,
    Config.NoComplete)

  Config.TryBindKey("Alt-C",
    "lua:CHXTemplates.CHXTypeTemplate|lua:CHXTemplates.CHXGlobalTemplate",
    false)
  Config.TryBindKey("Alt-G",
    "lua:CHXTemplates.CHXGlobalTemplate|lua:CHXTemplates.CHXTypeTemplate",
    false)
  Config.TryBindKey("Alt-N", "lua:CHXTemplates.CHXNextPH", false)
  Config.TryBindKey("Shift-F1", "lua:CHXTemplates.CHXListTypeTemplates", false)
  Config.TryBindKey("Ctrl-F1", "lua:CHXTemplates.CHXListGlobalTemplates", false)

  Config.AddRuntimeFile("CHXTemplates", Config.RTHelp, "CHXTemplates.md")
  Config.AddRuntimeFilesFromDirectory("CHXTemplates", RTCHXTypeTemplates,
    "TypeTemplates", "*.lua")
  Config.AddRuntimeFilesFromDirectory("CHXTemplates", RTCHXGlobalTemplates,
    "GlobalTemplates", "*.lua")
end

function onBeforeTextEvent(sbuf, ev)
-- Updating cached cursor positions
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

local function UTF8ToRunes(str)
-- Convert a string to UTF8 runes to deal with non ASCII characters.
-- TODO: This function is repeated in other CHX plugins, maybe it will be put
--   in .config/micro/init.lua to be global.
-- TODO 2: Is there any system, lua, micro function which do this?
  local runes = {}
  for char in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
    table.insert(runes, char)
  end
  return runes
end

local function GetGlobalFilename(keyword)
  local runes = UTF8ToRunes(keyword)
  if #runes == 0 then
    return "Symbol"
  end

  local firstRune = runes[1]

  if firstRune:match("^[0-9]$") then
    return "Number"
  end

  -- In a case-insensitive world...
  if firstRune:match("^[a-zA-Z]$") then
    return string.upper(firstRune)
  end

  -- Sorry other alphabets, mine too
  return "Symbol"
end

local function GetFileType(buf)
-- Gets filetype or its file extension
  local aFileType = buf:FileType()

  if (not aFileType) or (aFileType == "") or (aFileType == "unknown")
    or (aFileType == "default") then

    aFileType = string.gsub(FilePath.Ext(buf.Path), "\.", "")

    if aFileType == "" then
      -- File without extension.
      aFileType = "CHXText"
    end
  end
  return aFileType
end

local function GetKeyword(bp)
-- Get keyword from cursor position or the word at left.
-- Selects and returns the keyword found or `false` if none
  local c = bp.Cursor

  -- If there is selection use it. Anything goes.
  if c:HasSelection() then
    return Util.String(c:GetSelection())
  end

  -- This is simple if we only care about alphanumeric characters.
  -- Select word (or char) at cursor position
  -- TODO: Select "words" with other symbols?
  local keyword = Util.String(c:GetSelection(c:SelectWord()))
  if keyword:match("%S+") then return keyword end

  -- We are at the begining of the line
  if (c.X <= 0) then
    micro.InfoBar():Error("No keyword found")
    return ""
  end

  -- Select word (or symbol) at cursor's left
  c:Left()
  keyword = Util.String(c:GetSelection(c:SelectWord()))
  if keyword:match("%S+") then return keyword end

  c:ResetSelection()
  c:Right() -- Restore cursor position
  micro.InfoBar():Error("No keyword found")
  return ""
end

local function LoadTemplatesFile(RTTemplates, filename)
-- Load the template file from RTTemplates
-- Returns {["keyword1"] = "text1", ["keyword2"] = "text2", ...} or nil

  local TemplateFile = Config.ReadRuntimeFile(RTTemplates, filename)
  if (not TemplateFile) or (TemplateFile == "") then
    micro.InfoBar():Error("No template file for \"" .. filename .. "\" files.")
    return nil
  end

  local chunk, err = loadstring(TemplateFile)
  if err then
    micro.InfoBar():Error("Error in \"" .. filename .. ".lua\" file : " .. err)
    return nil
  end

  if chunk then
    local ok, res = pcall(chunk)
    if ok and type(res) == "table" then
      return res
    else
      micro.InfoBar():Error("Wrong return type(" .. type(res)
        .. ") from \"" .. filename .. ".lua\": " .. res)
      return nil
    end
  end
  return nil
end

local function ParseTemplate(rawTemplate, startX, startY, indent)
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
      -- Maybe we prefer at the start of the default text
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

local function PHCursors(bp, cursorlist)
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

local function InsertTemplate(bp, RTFiles, filename, keyword)
-- Insert a template.
-- Cursor must have selected the keyword to replace it with the template
  local buf = bp.Buf
  local c = bp.Cursor

  -- Just to assure that keyword is selected
  if not c:HasSelection() then
    micro.InfoBar():Error("¿Where is my selected keyword?")
    return false
  end

  local templates = LoadTemplatesFile(RTFiles, filename)
  if not templates then return false end

  local templateText = templates[keyword]
  if not templateText then
    micro.InfoBar():Error("No template for \"" .. keyword .. "\"")
    return false
  end

  -- Changing template internal tabs with buffer tab configuration
  if buf.Settings["tabstospaces"] then
    templateText = templateText:gsub("\t",
      buf:IndentString(tonumber(buf.Settings["tabsize"]) or 4))
  end

  -- Additional space in regex is a non-breakable space (0xA0)
  local indent = buf:Line(c.CurSelection[1].Y):match("^([  \t]*)") or ""

  -- If we remove keyword before getting current line we can have:
  --     [indent]keyword[spaces]... (and opcionally more text)
  -- And the indent will be mismatched as: [indent]+[spaces]
  c:DeleteSelection()
  c:ResetSelection()
  local startX = c.X
  local startY = c.Y

  local cleanText, phMap = ParseTemplate(templateText, startX, startY, indent)

  buf:Insert(Buffer.Loc(startX, startY), cleanText)

  -- Sorting placeholder indices
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

function CHXTypeTemplate(bp)
  local keyword = GetKeyword(bp)
  if keyword == "" then return false end

  local aFileType = GetFileType(bp.Buf)
  if aFileType  == "" then return false end

  return InsertTemplate(bp, RTCHXTypeTemplates, aFileType, keyword)
end

function CHXGlobalTemplate(bp)
  local keyword = GetKeyword(bp)
  if keyword == "" then return false end

  local aFileName = GetGlobalFilename(keyword)
  if aFileName  == "" then return false end

  return InsertTemplate(bp, RTCHXGlobalTemplates, aFileName, keyword)
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

  PHCursors(bp, phList.map[phList.indices[phList.currIdx]])

  micro.InfoBar():Message("Placeholder " .. phList.currIdx .. "/" ..
    #phList.indices .. " of \"" .. phList.Id .. "\" template.")

  return true
end

function CHXListTypeTemplates(bp)
  local filetype = GetFileType(bp.Buf)
  local templates = LoadTemplatesFile(RTCHXTypeTemplates, filetype)
  if not templates then return true end

  local lines = {}
  table.insert(lines,
    "========== Templates for: " .. filetype .. " ==========")
  -- table.insert(lines, "") -- added later

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
        table.insert(lines, "======== " .. k .. " ========")
        table.insert(lines, "")
    else
      local aLine = v:gsub("%s+", " ")
      aLine = aLine:gsub("{{(%d+)[^}]*}}", "$%1")

      -- Some template format alternatives
      aLine = string.format("  %-" .. longestKey .."s -> %s", k, aLine)
      -- aLine = string.format("[%-" .. longestKey .."s] -> %s", k, aLine)
      -- aLine = ":: " .. k .. "\n:=    " .. aLine -- if CHXText
      -- aLine = " " .. k .. "\n     " .. aLine

      aLine = string.sub(aLine, 1, bp:GetView().Width)
      if #lines == 1 then -- First title separation
        aLine = "\n" .. aLine
      end
      table.insert(lines, aLine)
    end
  end

  local content = table.concat(lines, "\n")
  local newBuf = Buffer.NewBuffer(content, filetype .. " templates")

  -- newBuf.Type = Buffer.BTInfo (= 5, not a Buftype) doesn't work
  newBuf.Type.Kind = 5
  newBuf.Type.Readonly = true
  newBuf.Type.Scratch = true
  newBuf.Type.Syntax = true

  -- TODO: Select between vertical or horizontal panel
  local newBP = bp:HSplitBuf(newBuf)
  newBuf:SetOption("softwrap", "false")
  newBuf:SetOption("filetype", "CHXText")

  micro.InfoBar():Message("Templates for \"" .. filetype .. "\"")
  return true
end

function CHXListGlobalTemplates(bp)

--[[
  Aquí habrá que preguntar por qué letra empieza o mostrar el listado de
  archivos...
]]--
  micro.InfoBar():Error("To be implemented")
  return true
end

