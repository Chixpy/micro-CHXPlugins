-- Templates of tcl for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

return {

--  #!/usr/bin/env tclsh
["!"] = "#!/usr/bin/env tclsh\n",

--  Process
["pro"] =
[[proc {{1:Name}} {{{2:Args}}} {
	{{3}}
}
{{9}}
]],

-- xif
["xif"] = "{{1:Expr}}? {{2:True}} : {{3:False}}",

--  Conditional
["if"] =
[[if {{{1}}} {
	{{2}}
}
{{9}}
]],

--  Conditional if..else
["ife"] =
[[if {{{1}}} {
	{{2}}
} else {
	{{3}}
}
{{9}}
]],

["eif"] =
[[elseif {{{1}}} {
	{{2}}
}
{{9}}
]],

--  Conditional if..elsif..else
["ifee"] =
[[if {{{1}}} {
	{{2}}
} elseif {{{3}}} {
	{{4}}
} else {
	{{5}}
}
{{9}}
]],

--  If catch then
["ifc"] =
[[if { [catch {{{1}}} {{2:Err}}] } {
	{{3}}
}
{{9}}
]],

--  Catch
["catch"] =
[[catch {{{1}}} {{2:Err}} {{3:options}}]],

--  While Loop
["wh"] =
[[while {{{1}}} {
	{{2}}
}
{{9}}
]],

--  For Loop
["for"] =
[[for {set {{1:Var}} 0} {${{2}} < {{1:Count}}} {{{3:Incr}} {{2}}} {
	{{4}}
}
{{9}}
]],

--  Foreach Loop
["fore"] =
[[foreach {{1:x}} {{{2:List}}} {
	{{3}}
}
{{9}}
]],

--  after ms script...
["af"] = "after {{1:ms}} {{2}}",

--  after cancel id
["afc"] = "after cancel {{1}}",

--  after idle
["afi"] = "after idle {{1}}",

--  after info id
["afin"] = "after info {{1}}",

--  Expr
["exp"] = "expr {{{1}}}",

--  Switch
["sw"] =
[[switch {{1}} {
	{{2}} {
		{{3}}
	}
	default {
		{{4}}
	}
}
{{9}}
]],

--  Case
["ca"] =
[[{{1}} {
	{{2}}
}
{{9}}
]],

--  Namespace eval
["ns"] =
[[namespace eval {{1}} {{{2}}}
{{9}}
]],

--  Namespace current
["nsc"] = "namespace current\n",
}
