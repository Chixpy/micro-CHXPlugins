-- Templates of zsh for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

return {

["!"] = "#!/bin/zsh\n",

["if"] =
[[if {{1}}; then
	{{2}}
fi
{{9}}]],

["ife"] =
[[if {{1}}; then
	{{2}}
else
	{{3}}
fi
{{9}}]],

["eif"] = "elif {{1}}; then\n\t{{2}}",

["for"] =
[[for (( {{1:i}} = 0; {{1}} < {{2:count}}; {{1}}++ )); do
	{{3}}
done
{{9}}]],

["fori"] =
[[for {{1:needle}} in {{2:haystack}}; do
	{{3}}
done
{{9}}]],

["fore"] =
[[for {{1:item}} in {${2}}; do
	{{3}}
done
{{9}}]],

["wh"] =
[[while {{1}}; do
	{{3}}
done
{{9}}]],

["until"] =
[[until {{1}}; do
	{{3}}
done
{{9}}]],

["repeat"] =
[[repeat {{1}}; do
	{{2}}
done
{{9}}]],

["case"] =
[[case {{1}} in
	{{2}})
		{{3}};;
	{{4}})
		{{5}};;
esac
{{9}}]],

["select"] =
[[select {{1:answer}} in {{2}}; do
	{{3}}
done
{{9}}]],

["("] =
[[(
	{{1}}
)
{{9}}]],

["{"] =
[[{
	{{1}}
}
{{9}}]],

["["] = "\n[[\n\t{{1}}\n]]\n",

["always"] =
[[{
	{{1}}
} always {
	{{2}}
}
{{9}}]],

["fun"] =
[[{{1}}() {
	{{2}}
}
{{9}}]],

["ffun"] =
[[function {{1}}() {
	{{2}}
}
{{9}}]],
}
