-- Templates of lua for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

local templates = {

["!"] = "#!/usr/bin/env lua\n",

["l"] = "local {{1}} = {{2}}\n",

["fun"] =
[[function {{1}}({{2}})
	{{3}}
	return {{4}}
end
{{9}}]],

["lfun"] =
[[local function {{1}}({{2}})
	{{3}}
	return {{4}}
end
{{9}}]],

["if"] =
[[if ({{2}}) then
	{{3}}
end
{{9}}]],

["ife"] =
[[if ({{2}}) then
	{{3}}
else
	{{4}}
end
{{9}}]],

["Iterations"] = "",

["for"] =
[[for {{1}}={{2}},{{3}} do
	{{4}}
end
{{9}}]],

["fori"] =
[[for {{1}},{{2}} in ipairs({{3}}) do
	{{4}}
end
{{9}}]],

["forp"] =
[[for {{1}},{{2}} in pairs({{3}}) do
	{{4}}
end
{{9}}]],

["while"] =
[[while ({{1}}) do
	{{2}}
end
{{9}}]],

}

return templates
