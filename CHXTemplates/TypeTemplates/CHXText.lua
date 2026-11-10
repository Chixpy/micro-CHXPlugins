-- Templates of CHX text style for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

local templates = {

-- Warning: Many templates use non-breakings spaces

-------- Headers
["Headers"] = "",

-- Six depths as HTML, but with inverted representation from other LML
-- Closing "==" are optional. [x]d are the default style.

["h1"] = string.rep("=", 79) .. "\n{{1:H1}}\n" .. string.rep("=", 79)
  .. "\n\n{{9}}",

["h1d"] = "== == == == == == {{1:H1}} == == == == == ==\n\n{{9}}",

["h2"] = string.rep("==" .. string.rep(" ", 17), 4) .. " ==\n{{1:H2}}\n"
  .. string.rep("=", 79) .. "\n\n{{9}}",

["h2d"] = "== == == == == {{1:H2}} == == == == ==\n\n{{9}}",

["h3"] = "== == == == {{1:H3}} == == == ==\n\n{{9}}",

["h3d"] = "== == == == {{1:H3}} == == == ==\n\n{{9}}",

["h4"] = "== == == {{1:H4}}\n\n{{9}}",

["h4d"] = "== == == {{1:H4}} == == ==\n\n{{9}}",

["h5"] = "==== {{1:H5}} ====\n\n{{9}}",

["h5d"] = "== == {{1:H5}} == ==\n\n{{9}}",

["h6"] = "== {{1:H6}}\n\n{{9}}",

["h6d"] = "== {{1:H6}} ==\n\n{{9}}",

-------- Lists
["Lists"] = "",

-- TODO: Make lists dinamic "[ul/ol/dl]<number>"

---- Unordered list

["ul"] = "· {{1}}\n· {{2}}",

["uld"] = "- {{1}}\n- {{2}}",

---- Ordered list

["ol"] = "# {{1}}\n# {{2}}",

["ol1"] = "1. {{1}}\n2. {{2}}",

["ola"] = "a. {{1}}\nb. {{2}}",

---- Definition list, yeah

["dl"] = ":: {{1}}\n:= {{2}}",

-------- Inline styles
["Inline styles"] = "",

---- Bold

["b"] = "**{{1}}**{{9}}",

-- Italic

["i"] = "//{{1}}//{{9}}",

---- Underline

["u"] = "__{{1}}__{{9}}",

---- Striked

["s"] = "~~{{1}}~~{{9}}",

---- Monospaced

["m"] = "||{{1}}||{{9}}",

---- Code

["c"] = "[[{{1}}]]{{9}}",

---- Code

["math"] = "$${{1}}$${{9}}",

-------- Block types
["Block types"] = "",

---- Code Block

["cb"] =
[[``{{{{1}}}}
{{2}}
``
{{9}}]],

---- Block quote

["bq"] =
[[<<{{{{1:Type}}}} {{2:Title}}
{{3}}
>> {{4}}
{{9}}]],

["cite"] =
[[<<{{Cite}} {{2:Title}}
{{3}}
>> {{4:Autor}}
{{9}}]],

["example"] =
[[<<{{Example}} {{2:Title}}
{{3}}
>> {{4}}
{{9}}]],

["hint"] =
[[<<{{Hint}} {{2:Title}}
💡 {{3}}
>> {{4}}
{{9}}]],

["info"] =
[[<<{{Information}} {{2:Title}}
{{3}}
>> {{4}}
{{9}}]],

["mono"] =
[[<<{{Monospaced}} {{2:Title}}
{{3}}
>> {{4}}
{{9}}]],

["note"] =
[[<<{{Note}} {{2:Title}}
📝 {{3}}
>> {{4}}
{{9}}]],

["pre"] =
[[<<{{Preformated}} {{2:Title}}
{{3}}
>> {{4}}
{{9}}]],

["todo"] =
[[<<{{Todo}} {{2:Title}}
⚙️ {{3}}
>> {{4}}
{{9}}]],

["warn"] =
[[<<{{Warning}} {{2:Title}}
⚠️ {{3}}
>> {{4}}
{{9}}]],

}

-- Alias

templates["Alias from previous keywords"] = ""

templates["code"] = templates["cb"]


return templates
