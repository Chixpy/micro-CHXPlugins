VERSION = "1.2.0"

local micro = import("micro")
local Config = import("micro/config")
local Buffer = import("micro/buffer")
local Util = import("micro/util")

function init()
  Config.MakeCommand("CHXSplitLines", CHXSplitLines, Config.NoComplete)
  Config.MakeCommand("CHXSplitLinesAt", CHXSplitLinesAt, Config.NoComplete)
  Config.TryBindKey("Alt-s", "lua:CHXSplitLines.CHXSplitLines", false)
  Config.TryBindKey("Alt-a", "lua:CHXSplitLines.CHXSplitLinesAt", false)
  Config.TryBindKey("Alt-S", "lua:CHXSplitLines.CHXJustifyLine", false)
  Config.TryBindKey("Alt-J", "lua:CHXSplitLines.CHXJustifyParagraph", false)
  Config.AddRuntimeFile("CHXSplitLines", Config.RTHelp, "CHXSplitLines.md")
end

local function UTF8ToRunes(str)
-- Convert a string to UTF8 runes to deal with non ASCII characters.
  local runes = {}
  for char in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
    table.insert(runes, char)
  end
  return runes
end

local function WrapText(oldText, limit)
  local newText = {}

  for textLine in string.gmatch(oldText .. "\n", "(.-)\r?\n") do
    -- Get initial indentation and actual right limit
    local indent, content = textLine:match("^([ \t]*)(.*)$")
    local indentRunes = UTF8ToRunes(indent)
    local indentLen = #indentRunes
    local actualLimit = limit - indentLen

    local lineRunes = UTF8ToRunes(textLine)
    if #lineRunes <= limit then
      table.insert(newText, textLine)
    elseif actualLimit <= 0 then
      -- Not sure what to do in this case (indent > limit)
      table.insert(newText, textLine)
    else
      local contentRunes = UTF8ToRunes(content)

      while #contentRunes > actualLimit do
        -- Search last space inside the UTF8 runes
        local spaceIdx = nil
        for i = actualLimit, 1, -1 do
          if contentRunes[i] == " " then
            spaceIdx = i
            break
          end
        end

        if spaceIdx then
          -- Cut at last space found
          table.insert(newText,
            indent .. table.concat(contentRunes, "", 1, spaceIdx - 1))

          -- Next text to parse
          local newContent = {}
          for i = spaceIdx + 1, #contentRunes do
            table.insert(newContent, contentRunes[i])
          end
          contentRunes = newContent
        else -- not spaceIdx
          -- If there is not space before the limit, search for the first found.
          local nextSpace = nil
          for i = actualLimit + 1, #contentRunes do
            if contentRunes[i] == " " then
              nextSpace = i
              break
            end
          end

          if nextSpace then
            table.insert(newText,
              indent .. table.concat(contentRunes, "", 1, nextSpace - 1))
            local newContent = {}
            for i = nextSpace + 1, #contentRunes do
              table.insert(newContent, contentRunes[i])
            end
            contentRunes = newContent
          else
            break
          end
        end
      end -- while #contentRunes > actualLimit
      table.insert(newText, indent .. table.concat(contentRunes, ""))
    end -- if #lineRunes > limit and actualLimit > 0
  end -- for textLine
  return table.concat(newText, "\n")
end

local function JustParagraph(oldParagraph, limit, jSingleLine)
  local wrappedText = WrapText(oldParagraph, limit)

  local lines = {}
  for line in string.gmatch(wrappedText .. "\n", "(.-)\r?\n") do
    table.insert(lines, line)
  end

  local justifiedLines = {}
  local totalLines = #lines

  for idx, line in ipairs(lines) do
    if ((totalLines == 1) and (not jSingleLine)) -- One line paragraph
    or ((totalLines > 1) and (idx == totalLines)) then
      -- Last line kept as is.
      table.insert(justifiedLines, line)
    else
      local indent, content = line:match("^([ \t]*)(%S.*)$")
      if not content then
        -- Empty line... must not happen but keep as is
        table.insert(justifiedLines, line)
      else
        local words = {}
        for w in content:gmatch("%S+") do table.insert(words, w) end

        if #words <= 1 then
          table.insert(justifiedLines, line)
        else
          local wordsLen = 0
          for _, w in ipairs(words) do
            wordsLen = wordsLen + Util.CharacterCountInString(w)
          end

          local numGaps = #words - 1
          local baseLen = Util.CharacterCountInString(indent)
            + wordsLen + numGaps
          local extraSpaces = limit - baseLen

          if extraSpaces <= 0 then
            table.insert(justifiedLines, line)
          else
            -- Actual spaces betweem words
            local spacesPerGap = {}
            for i = 1, numGaps do spacesPerGap[i] = 1 end

            -- Distributing extra spaces
            for i = 1, extraSpaces do
              local gapIndex = ((i - 1) % numGaps) + 1
              spacesPerGap[gapIndex] = spacesPerGap[gapIndex] + 1
            end

            -- Joining line again
            local resLine = indent
            for i = 1, #words do
              resLine = resLine .. words[i]
              if i <= numGaps then
                resLine = resLine .. string.rep(" ", spacesPerGap[i])
              end
            end
            table.insert(justifiedLines, resLine)
          end
        end
      end
    end
  end

  return table.concat(justifiedLines, "\n")
end

function CHXSplitLines(bp)
-- Split cursor's line or lines in selection at `colorcolumn` width.
  local buf = bp.Buf
  local c = bp.Cursor
  local cc = buf.Settings["colorcolumn"]
  local limit = (type(cc) == "number" and cc > 0) and cc or 80

  -- Start and End lines
  local startLine, endLine = -1, -1
  if c:HasSelection() then
    startLine = c.CurSelection[1].Y
    endLine = c.CurSelection[2].Y
  else
    startLine = c.Y
    endLine = c.Y
  end

  if startLine ~= -1 and endLine ~= -1 then
    -- Processing lines in inverted orded (original line numbers don't change)
    for lineNum = endLine, startLine, -1 do
      local oldText = buf:Line(lineNum)
      local indent, newText = oldText:match("^([ \t]*)(.*)$")
      -- Removing repeated whitespaces in content only
      newText = indent .. string.gsub(newText, "%s+", " ")

      buf:Replace(
        Buffer.Loc(0, lineNum),
        Buffer.Loc(Util.CharacterCountInString(oldText), lineNum),
        WrapText(newText, limit))
    end
  end

  if c:HasSelection() then
    c:ResetSelection() -- Initial selection is restored on Undo
  end
end

function CHXSplitLinesAt(bp)
-- Ask for a character and splits cursor's line (or selected text) at it.
  micro.InfoBar():Prompt("Split at char: ", "", "splitAtChar", nil,
  function (resp, canceled)
    if canceled or resp == "" then
      return
    end
    local escResp = string.gsub(resp, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")

    local buf = bp.Buf
    local c = bp.Cursor
    local textStart, textEnd = -1, -1 -- Start and end of the text to wrap

    if not c:HasSelection() then
      -- Selecting whole line
      local lineNum = c.Y
      local lineText = buf:Line(c.Y)

      textStart = Buffer.Loc(0, lineNum)
      textEnd = Buffer.Loc(Util.CharacterCountInString(lineText), lineNum)
      c:SetSelectionStart(textStart)
      c:SetSelectionEnd(textEnd)
    end;
    textStart = Buffer.Loc(c.CurSelection[1].X, c.CurSelection[1].Y)
    textEnd = Buffer.Loc(c.CurSelection[2].X, c.CurSelection[2].Y)

    local newText = Util.String(c:GetSelection())
    newText = string.gsub(newText, escResp, resp .. "\n")
    newText = string.gsub(newText, "[ %t]*\n[ %t]*", "\n")

    buf:Replace(textStart, textEnd, newText)
    c:ResetSelection()
  end)
end

function CHXJustifyLine(bp)
  local buf = bp.Buf
  local c = bp.Cursor
  local cc = buf.Settings["colorcolumn"]
  local limit = (type(cc) == "number" and cc > 0) and cc or 80

  -- Initial Start and End lines
  local startLine, endLine = -1, -1
  if c:HasSelection() then
    startLine = c.CurSelection[1].Y
    endLine = c.CurSelection[2].Y
  else
    startLine = c.Y
    endLine = c.Y
  end

  -- Processing lines in inverted orded (original line numbers don't change)
  while (endLine >= startLine) do
    oldText = buf:Line(endLine)

    -- Getting indent
    local indent, newText = oldText:match("^([ \t]*)(.*)$")
    -- Removing repeated whitespaces in content only
    newText = indent .. string.gsub(newText, "%s+", " ")
    newText = JustParagraph(newText, limit, true)

    buf:Replace(
       Buffer.Loc(0, endLine),
       Buffer.Loc(Util.CharacterCountInString(oldText), endLine),
       newText)

    endLine = endLine - 1
  end
  if c:HasSelection() then
    c:ResetSelection() -- Initial selection is restored on Undo
  end
end

function CHXJustifyParagraph(bp)
  local buf = bp.Buf
  local c = bp.Cursor
  local cc = buf.Settings["colorcolumn"]
  local limit = (type(cc) == "number" and cc > 0) and cc or 80

  -- Initial Start and End lines
  local startLine, endLine = -1, -1
  if c:HasSelection() then
    startLine = c.CurSelection[1].Y
    endLine = c.CurSelection[2].Y
  else
    startLine = c.Y
    endLine = c.Y
  end

  -- Searching the first line of first paragraph
  while (startLine > 0)
  and (not buf:Line(startLine - 1):match("^%s*$")) do
    startLine = startLine - 1
  end

  -- Searching the last line of last paragraph
  while (endLine < buf:LinesNum() - 2)
  and (not buf:Line(endLine + 1):match("^%s*$")) do
    endLine = endLine + 1
  end

  -- Searching individual paragraphs inside selection
  local currLine = endLine
  while (currLine >= startLine) do
    -- Serching first line of last paragraph
    while currLine > startLine
    and (not buf:Line(currLine - 1):match("^%s*$")) do
      currLine = currLine - 1
    end

    -- Joining paragraph lines
    local oldParagraph = buf:Line(currLine)
    for lineNum = currLine + 1, endLine do
      oldParagraph = oldParagraph .. " " .. buf:Line(lineNum)
    end

    -- Getting indent
    local indent, newText = oldParagraph:match("^([ \t]*)(.*)$")
    -- Removing repeated whitespaces in content only
    newText = indent .. string.gsub(newText, "%s+", " ")
    newText = JustParagraph(newText, limit, false)

    buf:Replace(
      Buffer.Loc(0, currLine),
      Buffer.Loc(Util.CharacterCountInString(buf:Line(endLine)), endLine),
      newText)

    -- Serching last line of previous paragraph
    repeat
      currLine = currLine - 1
    until (currLine <= startLine)
    or (not buf:Line(currLine):match("^%s*$"))
    endLine = currLine
  end
  if c:HasSelection() then
    c:ResetSelection() -- Initial selection is restored on Undo
  end
end;
