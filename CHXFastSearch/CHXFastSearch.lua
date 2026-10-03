VERSION = "1.0.0"

local Config = import("micro/config")

function CHXNextWord(bp)
  local c = bp.Cursor
  if not c:HasSelection() then
    c:SelectWord()
  end
  local word = c:GetSelection()
  bp.Buf.LastSearch = word -- Actualizamos última busqueda
  bp:FindNext()
end

function CHXPrevWord(bp)
  local c = bp.Cursor
  if not c:HasSelection() then
    c:SelectWord()
  end
  local word = c:GetSelection()
  bp.Buf.LastSearch = word -- Actualizamos última busqueda
  bp:FindPrevious()
end


function init()
  Config.MakeCommand("CHXPrevWord", CHXPrevWord, Config.NoComplete)
  Config.MakeCommand("CHXNextWord", CHXNextWord, Config.NoComplete)
  Config.TryBindKey("Alt-k", "lua:CHXFastSearch.CHXPrevWord", false)
  Config.TryBindKey("Alt-l", "lua:CHXFastSearch.CHXNextWord", false)
  Config.AddRuntimeFile("CHXFastSearch", Config.RTHelp, "CHXFastSearch.md")
end
