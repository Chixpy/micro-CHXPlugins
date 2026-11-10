-- Templates of Vim script for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

local templates = {
--  standard Vim script file header
["header"] =
[[" File: {{1:`expand('%:t')`}}
" Author: {{2:`g:snips_author`}}
" Description: {{3}}
{{4:" Last Modified: `strftime("%B %d, %Y")`}}
]],

-- script reload guard
["guard"] =
[[if exists('{{1:did_`vim_snippets#Filename()`}}') || &cp{{2: || version < 700}}
	finish
endif
let {{1}} = 1{{3}}
]],

-- function
["f"] =
[[fun! {{1:`expand('%') =~ 'autoload' ? substitute(matchstr(expand('%:p'),'autoload/\zs.*\ze.vim'),'[/\\]','#','g').'#' : ''`}}{{2:function_name}}({{3}})
	{{4}}
endf
{{9}}
]],

-- try ... catch statement
["t"] =
[[try
	{{1}}
catch {{2}}
	{{3}}
endtry
{{9}}
]],

-- for ... in loop
["for"] =
[[for {{1}} in {{2}}
	{{3}}
endfor
{{9}}
]],

-- for [key, value] in loop
["forkv"] =
[[for [{{1}},{{2}}] in items({{3}})
	{{4}}
	unlet {{1}} {{2}}
endfor
{{9}}
]],

-- while loop
["wh"] =
[[while {{1}}
	{{2}}
endw
{{9}}
]],

-- if statement
["if"] =
[[if {{1}}
	{{2}}
endif
{{9}}
]],

-- if ... else statement
["ife"] =
[[if {{1}}
	{{2}}
else
	{{3}}
endif
{{9}}
]],

-- augroup ... autocmd block
["au"] =
[[augroup {{1:AU_NAME}}
	" this one is which you're most likely to use?
	autocmd {{2:BufRead,BufNewFile}} {{3:*.ext,*.ext3|<buffer[=N]>}} {{9}}
augroup end
]],

-- Vundle.vim Plugin definition
["bun"] = "Plugin '{{1}}'\n{{9}}",
}

-- Alias
templates["plug"] = templates["bun"]

return templates

