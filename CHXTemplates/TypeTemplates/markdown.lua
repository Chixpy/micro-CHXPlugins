-- Generador dinámico de tablas Markdown según el patrón mdtable<filas>x<columnas>
--[[
local numRows, numCols = key:match("^mdtable(%d+)x(%d+)$")
if numRows then
    local r, c = tonumber(numRows), tonumber(numCols)
    local lines = {}

    -- Cabecera
    local header = "|"
    local sep = "|"
    for j = 1, c do
        header = header .. " Columna " .. j .. " |"
        sep = sep << " --- |" -- o concatenación normal
    end
    -- ...
end
]]--
return ""
