VERSION = "1.0.0"

local micro = import("micro")
local Config = import("micro/config")
local Buffer = import("micro/buffer")
local Util = import("micro/util")


function init()
  Config.MakeCommand("CHXPrevWord", CHXPrevWord, Config.NoComplete)
  Config.MakeCommand("CHXNextWord", CHXNextWord, Config.NoComplete)
  Config.TryBindKey("Alt-k", "lua:CHXFastSearch.CHXPrevWord", false)
  Config.TryBindKey("Alt-l", "lua:CHXFastSearch.CHXNextWord", false)
  Config.AddRuntimeFile("CHXFastSearch", Config.RTHelp, "CHXFastSearch.md")
end

function CHXNextWord(bp)
  if not bp.Cursor:HasSelection() then
    bp.Cursor:SelectWord()
  end

  -- HACK:
  -- bp:Search will not go to next searched term if selection is made
  -- backwards (right to left or going up) because the cursor is at the start
  -- of the selection and current selection is actually a match. It will work
  -- as expected after a second call because the term will be selected left
  -- to right.
  --
  -- To work as expected from first call, we need to move the cursor to the end
  -- of the selection.

  -- TODO: Not sure why this not work well:
  -- bp.Cursor.Loc = {bp.Cursor.CurSelection[2]}
  bp.Cursor.Loc = Buffer.Loc(bp.Cursor.CurSelection[2].X,
    bp.Cursor.CurSelection[2].Y)

  -- bp:Search(String, UseRegex, GoDown)
  local aError = bp:Search(Util.String(bp.Cursor:GetSelection()), false, true)

  if aError then
    micro.InfoBar():Error(aError:Error())
    return false
  end
  return true
end

function CHXPrevWord(bp)
  if not bp.Cursor:HasSelection() then
    bp.Cursor:SelectWord()
  end

  -- HACK:
  -- Same problem that CHXNextWord but this time it's worse. If term is selected
  -- left to right (and bp.Cursor:SelectWord() does it this way), bp:Search
  -- will match current selection. As it will be select again left to right
  -- search will not move never again. If term was selected manually right to
  -- left it will move only once, as it will enter in the previus loop.
  --
  -- To work as expected we need to move the cursor to the start of the
  -- selection.

  -- TODO: Not sure why this not work well:
  -- bp.Cursor.Loc = {bp.Cursor.CurSelection[1]}
  bp.Cursor.Loc = Buffer.Loc(bp.Cursor.CurSelection[1].X,
    bp.Cursor.CurSelection[1].Y)

  -- bp:Search(String, UseRegex, GoDown)
  local aError = bp:Search(Util.String(bp.Cursor:GetSelection()), false, false)

  if aError then
    micro.InfoBar():Error(aError:Error())
    return false
  end
  return true
end
