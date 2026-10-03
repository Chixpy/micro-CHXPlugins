VERSION = "1.1.0"

local micro = import("micro")
local Config = import("micro/config")
local Buffer = import("micro/buffer")
local Util = import("micro/util")

local function WrapText(text, limit)
-- Función auxiliar para procesar un texto y envolverlo a N columnas
-- respetando palabras.
  local Result = {}

  -- Procesamos el texto línea por línea original
  for line in string.gmatch(text .. "\n", "(.-)\r?\n") do
    while #line > limit do
      -- Buscamos el último espacio dentro del límite.
      local sub = string.sub(line, 1, limit)
      local spaceIdx = string.match(sub, ".*() ")

      if spaceIdx then
        -- Cortamos por el espacio encontrado
        table.insert(Result, string.sub(line, 1, spaceIdx - 1))
        line = string.sub(line, spaceIdx + 1)
      else
        -- Si no hay espacio antes límite (palabra muy larga),
        -- buscamos el primer espacio que aparezca después
        local nextSpace = string.find(line, " ", limit + 1)
        if nextSpace then
          table.insert(Result, string.sub(line, 1, nextSpace - 1))
          line = string.sub(line, nextSpace + 1)
        else
          -- No hay más espacios en toda la línea
          break
        end
      end
    end
    table.insert(Result, line)
  end

  return table.concat(Result, "\n")
end

function CHXSplitLines(bp)
-- Divide la línea actual (o seleccionadas) en lineas que no pasen del
-- limite de colorcolumn u 80 si no esta definido
  local buf = bp.Buf
  local cc = buf.Settings["colorcolumn"]
  local limit = (type(cc) == "number" and cc > 0) and cc or 80
  local a, b = -1, -1 -- Text to wrap begin and end
  local c = bp.Cursor

  if c:HasSelection() then
    -- Obtenemos las líneas completas que tengan algo seleccionado
    a = Buffer.Loc(0, c.CurSelection[1].Y)
    -- Falla con acentos y no ASCII:
    -- b = Buffer.Loc(#buf:Line(c.CurSelection[2].Y), c.CurSelection[2].Y)
    b = Buffer.Loc(
      Util.CharacterCountInString(buf:Line(c.CurSelection[2].Y)),
      c.CurSelection[2].Y)
    c:SetSelectionStart(a)
    c:SetSelectionEnd(b)

    local selectedText = Util.String(c:GetSelection())
    local wrapped = WrapText(selectedText, limit)

    buf:Replace(a, b, wrapped)
    c:ResetSelection()
  else
    -- Si no hay selección, toma la línea completa donde está el cursor
    local lineNum = c.Y
    local lineText = buf:Line(lineNum)

    if #lineText > limit then
      local wrapped = WrapText(lineText, limit)

      a = Buffer.Loc(0, lineNum)
      b = Buffer.Loc(#lineText, lineNum)

      buf:Replace(a, b, wrapped)
    end
  end
end

function CHXSplitLinesAt(bp)
-- Pide un carácter y divide la línea actual en cada coincidencia del texto.
  micro.InfoBar():Prompt("Split at char: ", "", "splitAtChar", nil,
  function (resp, canceled)
    resp = Util.String(resp) -- Ouch...
    if canceled or resp == "" then
      return
    end

    local buf = bp.Buf
    local c = bp.Cursor

    if c:HasSelection() then
      local text = Util.String(c:GetSelection())
      local escapedResp = string.gsub(resp, "[%^%$%(%)%%%.%[%]%*%+%-%?]",
        "%%%1")
      local newText = string.gsub(text, escapedResp, resp .. "\n")
      newText = string.gsub(newText, "[ %t]*\n[ %t]*", "\n")

      a = Buffer.Loc(c.CurSelection[1].X, c.CurSelection[1].Y)
      b = Buffer.Loc(c.CurSelection[2].X, c.CurSelection[2].Y)
      buf:Replace(a, b, newText)
    end
  end)
end

function init()
  Config.MakeCommand("CHXSplitLines", CHXSplitLines, Config.NoComplete)
  Config.MakeCommand("CHXSplitLinesAt", CHXSplitLinesAt, Config.NoComplete)
  Config.TryBindKey("Alt-s", "lua:CHXSplitLines.CHXSplitLines", false)
  Config.TryBindKey("Alt-Shift-s", "lua:CHXSplitLines.CHXSplitLinesAt", false)
  Config.AddRuntimeFile("CHXSplitLines", Config.RTHelp, "CHXSplitLines.md")
end
