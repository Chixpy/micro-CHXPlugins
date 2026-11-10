-- Templates of XML for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

return {
-- Header
["xml"] = '<?xml version="1.0" encoding="UTF-8"?>\n',

-- tag
["t"] =
[[<{{1}}>
	{{2}}
</{{1}}>
{{3}}]],

-- inline tag
["ti"] = "<{{1}}>{{2}}</{{1}}>{{3}}",

}
