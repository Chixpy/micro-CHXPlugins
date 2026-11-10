-- Templates of Python for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

local templates = {

["env"] =
[[#!/usr/bin/env python
# -*- coding: utf-8 -*-
]],

["env3"] =
[[#!/usr/bin/env python3
# -*- coding: utf-8 -*-
]],

["imp"] = [[import {{1}}]],

["uni"] =
[[def __unicode__(self):
	{{1}}
]],

["from"] = [[from {{1}} import {{2}}]],

--  Module Docstring
["docs"] =
[["""
File: {{1:`vim_snippets#Filename('$1.py', 'foo.py')`}}
Author: `g:snips_author`
Email: `g:snips_email`
Github: `g:snips_github`
Description: {{2}}
"""

{{9}}
]],

["wh"] =
[[while {{1}}:
	{{2}}
{{9}}
]],

--  dowh - does the same as do...while in other languages
["dowh"] =
[[while True:
	{{1}}
	if {{2}}:
		break
{{9}}
]],

["with"] =
[[with {{1}} as {{2}}:
	{{3}}
{{9}}
]],

--  New Class
["cl"] =
[[class {{1}}({{2}}):
	"""{{3:docstring"""
	def __init__(self, {{4}}):
		{{5:super({{1}}, self).__init__()}}
		self.{{4}} = {{4}}
		{{6}}
{{9}}
]],

--  New Function
["def"] =
[[def {{1}}({{2:`indent('.') ? 'self' : ''`}}):
	"""{{3:docstring}}"""
	{{4}}
{{9}}
]],

["deff"] =
[[def {{1}}({{2:`indent('.') ? 'self' : ''`}}):
	{{3}}
{{9}}
]],

--  New Method
["defm"] =
[[def {{1}}(self, {{2}}):
	{{0}}
{{9}}
]],

--  New Property
["property"] =
[[def {{1}}():
	doc = "{{1}}"
	def fget(self):
		return self._{{1}}
	def fset(self, value):
		self._{{1}} = value
	def fdel(self):
		del self._{{1}}
	return locals()
{{1}} = property(**{{1}}())
{{9}}
]],

--  Ifs
["if"] =
[[if {{1}}:
	{{2}}
{{9}}
]],

["el"] =
[[else:
	{{1}}
{{9}}
]],

["ei"] =
[[elif {{1:condition}}:
	{{2}}
{{9}}
]],

--  For
["for"] =
[[for {{1:item}} in {{2:items}}:
	{{2}}
{{9}}
]],

--  Encodes
["cutf8"] = [[# -*- coding: utf-8 -*-\n]],

["clatin1"] = [[# -*- coding: latin-1 -*-\n]],

["cascii"] = [[# -*- coding: ascii -*-\n]],

--  Lambda
["ld"] = [[{{1}} = lambda {{2}} : {{3}}]],

["."] = [[self.]],


-- Try/Except
["trye"] =
[[try:
	{{1}}
except {{2:Exception}}, {{3:e}}:
	raise {{3}}
{{9}}
]],

-- Try/Except/Else
["tryee"] =
[[try:
	{{1}}
except {{2:Exception}}, {{3:e}}:
	raise {{3}}
else:
	{{9}}
{{9}}
]],

-- Try/Except/Finally
["tryef"] =
[[try:
	{{1}}
except {{2:Exception}}, {{3:e}}:
	raise {{3}}
finally:
	{{9}}
{{9}}
]],

-- Try/Except/Else/Finally
["tryeef"] =
[[try:
	{{1}}
except {{2:Exception}}, {{3:e}}:
	raise {{3}}
else:
	{{5}}
finally:
	{{6}}
{{9}}
]],

--  if __name__ == '__main__':
["ifmain"] =
[[if __name__ == '__main__':
	{{0:main()}}
]],

--  __magic__
["_"] = [[__{{1:init}}__\n{{9}}]],

--  python debugger (pdb)
["pdb"] =
[[import pdb
pdb.set_trace()
]],

--  bpython debugger (bpdb)
["bpdb"] =
[[import bpdb
bpdb.set_trace()
]],

--  ipython debugger (ipdb)
["ipdb"] =
[[import ipdb
ipdb.set_trace()
]],

--  embed ipython itself
["iem"] =
[[import IPython
IPython.embed()
]],

--  ipython debugger (pdbbb)
["pdbbb"] =
[[import pdbpp
pdbpp.set_trace()
]],

--  remote python debugger (rpdb)
["rpdb"] =
[[import rpdb
rpdb.set_trace()
]],

--  ptpython
["ptpython"] =
[[from ptpython.repl import embed
embed(globals(), locals(), vi_mode={{1:False}}, history_filename={{2:None}})
]],

--  python console debugger (pudb)
["pudb"] =
[[import pudb
pudb.set_trace()
]],

--  pdb in nosetests
["nosetrace"] =
[[from nose.tools import set_trace
set_trace()
]],

["pprint"] =
[[import pprint
pprint.pprint({{1}})
]],

["\""] =
[["""
	{{1}}
"""
{{9}}
]],

--  assertions
["a="] = [[self.assertEqual({{0}}, {{1}})\n{{9}}]],

--  test function/method
["test"] =
[[def test_{{1}({{2:`indent('.') ? 'self' : ''`}}):
	{{0}}
{{9}}
]],

--  test case
["testcase"] =
[[class {{1:ExampleCase}}(unittest.TestCase):

	def test_{{2}}(self):
		{{3}}
{{9}}
]],

["fut"] = [[from __future__ import {{0}}]],

-- getopt
["getopt"] =
[[try:
	# Short option syntax: "hv:"
	# Long option syntax: "help" or "verbose="
	opts, args = getopt.getopt(sys.argv[1:], "{{1:short_options}}", [{{2:long_options}}])

except getopt.GetoptError, err:
	# Print debug info
	print str(err)
	{{3:error_action}}

for option, argument in opts:
	if option in ("-h", "--help"):
		{{4}}
	elif option in ("-v", "--verbose"):
		verbose = argument
{{9}}
]],

--  logging
--  glog = get log
["glog"] =
[[import logging
logger = logging.getLogger({{1:__name__}})
{{9}}
]],

["le"] =
[[logger.error({{1}})
{{9}}
]],

--  conflict with lambda=ld, therefor we change into Logger.debuG
["lg"] =
[[logger.debug({{1}})
{{9}}
]],

["lw"] =
[[logger.warning({{1}})
{{9}}
]],

["lc"] =
[[logger.critical({{1}})
{{9}}
]],

["li"] =
[[logger.info({{1}})
{{9}}
]],

["epydoc"] =
[["""{{1:Description}}

@param {{2:param}}: {{3: Description}}
@type  {{2}}: {{4: Type}}

@return: {{5: Description}}
@rtype : {{6: Type}}

@raise e: {{7: Description}}
"""
{{9}}
]],

["dol"] =
[[def {{1:__init__}}(self, *args, **kwargs):
	super({{2:ClassName}}, self).{{1}}(*args, **kwargs)
{{9}}
]],

["kwg"] =
[[self.{{1}} = kwargs.get('{{1}}', {{2:None}})
{{9}}
]],

["lkwg"] =
[[{{1}} = kwargs.get('{{1}}', {{2:None}})
{{9}}
]],

["args"] = [[*args{{1:,}}{{2}}]],

["kwargs"] = [[**kwargs{{1:,}}{{2}}]],

["akw"] = [[*args, **kwargs{{1:,}}{{2}}]],
}

return templates
