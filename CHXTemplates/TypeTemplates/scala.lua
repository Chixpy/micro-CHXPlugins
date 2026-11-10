-- Templates of CHX text style for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

-- Adapted from:
-- © Copyright 2011 Konstantin Gorodinskiy. All Rights Reserved.
-- Do What The Fuck You Want To Public License, Version 2.
-- See http://sam.zoy.org/wtfpl/COPYING for more details.

return {

------ Scala lang
-- if
["if"] =
[[if ({{1}})
	{{2}}
]],

-- if not
["ifn"] =
[[if (!{{1}})
	{{2}}
]],

-- if-else
["ife"] =
[[if ({{1}})
	{{2}}
else
	{{3}}
]],

-- if-else-if
["ifelif"] =
[[if ({{1}})
	{{2}}
else if ({{3}})
	{{4}}
]],

["eif"] =
[[else if ({{3}})
	{{4}}
]],

-- while loop
["wh"] =
[[while ({{1:obj}}) {
	{{2}}
}
{{9}}
]],

-- for loop(classic)
["for"] =
[[for ({{1:item}} <- {{2:obj}}) {
	{{3}}
}
{{9}}
]],

-- for loop(indexed)
["fori"] =
[[for ({{1:i}} <- {{2:0}} to {{3:obj}}.length) {
	{{4}}
}
{{9}}
]],

-- for comprehension
["fory"] =
[[for {
	{{1:item}} <- {{2:obj}}
} yield {{3}}
]],

-- exceptions
["try"] =
[[try {
	{{1}}
} catch {
	case e: FileNotFoundException => {{2}}
	case e: IOException => {{3}}
} finally {
	{{4}}
}
{{9}}
]],

-- match
["match"] =
[[{{1: obj}} match {
	case {{2:e}} => {{3}}
	case _ => {{4}}
}
{{9}}
]],

-- case
["case"] = "case {{1:value}} => {{2}}",

-- ###########################
--  methods and arguments
--
-- arg
["arg"] = "{{1:a}}: {{2:T}}{{3:, arg}}",

-- args
["args"] = "{{1:args}}: {{2:T}}*",

-- def
["def"] = "def {{1:name}}({{2:arg}}) = {{3:}}",

-- private def
["prdef"] = 'private def {{1:name}}({{2:arg}}) = {{3:}}',

-- override def
["ovdef"] = "override def {{1:name}}({{2:arg}}) = {{3:}}",

-- first class function(see scalabook p 188)
["fcf"] = "({{1:a}}: {{2:T}}) => {{1}} {{3}}",

["=>"] = "{{1:name}} => {{2}}",

-- recursion
["rec"] =
[[def {{1:name}}({{0:arg}}) =
	if({{2}}) {{2}}
	else {{1}}({{2}})
{{9}}
]],

-- curried method
["crdef"] = "def {{1:name}}({{2:arg}})({{3:arg}}) = {{4:}}",

-- main method
-- check validity of T
["main"] = "def main(args: Array[String]):{{1:T}} = {{4:}}",

-- named snippets for types
["bool"] = "Boolean",

["anyr"] = "AnyRef",

["dbl"] = "Double",

["int"] = "Int",

["str"] = "String",

["chr"] = "Char",

["lng"] = "Long",

["arr"] = "Array{{1:[T]}}{{2:()}}",

["buf"] = "Buffer{{1:[T]}}{{2:()}}",

["list"] = "List{{1:[T]}}{{2:()}}",

["tpl"] = "Tuple{{1:2}}[{{2:T}},{{3:T}}]",

["set"] = "Set{{1:[T]}}{{2:()}}",

["hset"] = "HashSet{{1:[T]}}{{2:()}}",

["mhset"] = "mutable.HashSet{{1:[T]}}{{2:()}}",

-- for maps
["keyval"] = "{{1:key}}->{{2:val}}{{3:, keyval}}",

["map"] = "Map[{{1:T}},{{2:T}}]{{3:(keyval)}}",

["hmap"] = "HashMap[{{1:T}},{{2:T}}]{{4:(keyval)}}",

["mmap"] = "mutable.Map[{{1:T}},{{2:T}}]{{3:(keyval)}}",

["mhmap"] = "mutable.HashMap[{{1:T}},{{2:T}}]{{3:(keyval)}}",

-- TODO add TreeMap and TreeSet
-- asInstanceOf[]
["as"] = "{{1:name}}.asInstanceOf[{{2:T}}]",

-- isInstanceOf[]
["is"] = "{{1:name}}.isInstanceOf[{{2:T}}]",

-- collections methods

-- scope() with one arg
["(a"] = "({{1:a}} => {{2}})",

-- scope() with two args
["{("] =
[[{({{1:a}},{{2:b}}) =>
	{{3}}
}
{{9}}
]],

-- filter
["filter"] = "{{0:name}}.filter (a",

-- map function
["mapf"] = "{{0:name}}.map (a",

-- flatmap
["flatmap"] = "{{1:name}}.flatMap{{2:[T]}}(a",

-- fold left
["fldl"] = "{{1:name}}.foldLeft({{2:first}}) {(",

-- fold right
["fldr"] = "{{1:name}}.foldRight({{2:first}}) {(",

-- fold left operator(if u wanna reduce readability of ur code)
-- use wildcard symbols
["/:"] = "({{1:first}}/:{{2:name}})({{3}})",

-- fold right operator
[":\ "] = "({{1:first}}:\{{2:name}})({{3}})",

-- reduce left
["redl"] = "{{1:name}}.reduceLeft[{{2:T}}] {(",

-- reduce right
["redr"] = "{{1:name}}.reduceRight[{{2:T}}] {(",

-- zipWithIndex(safe way).
-- see http://daily-scala.blogspot.com/2010/05/zipwithindex.html
["zipwi"] = "{{0:name}}.view.zipWithIndex",

-- split
["spl"] = '{{1:name}}.split("{{2:,}}")',
-- end

["val"] = "val {{1:name}}{{2:: T}} = {{3:value}}",

["var"] = "var {{1:name}}{{2:: T}} = {{3:value}}",

-- ###########################
--  classes
--
-- extends
["extends"] = "extends {{0:what}}",

-- with
["with"] = "with {{1:what}}{{2: with}}",

-- auxiliary constructor(a. this)
["athis"] = "def this(arg) = this(arg)",

-- abstract class
["abstract"] =
[[abstract class {{1:name}}{{2:(arg)}}{{3: extends }}{{4: with}} {
	{{5:override def toString = "{{1}}"}}
	{{6}}
}
{{9}}
]],

-- class
["class"] =
[[class {{1:name}}{{2:(arg)}}{{3: extends }}{{4: with}} {
	{{5:override def toString = "{{1}}"}}
	{{6}}
}
{{9}}
]],

-- object
["object"] = "object {{1:name}}{{2:(arg)}}{{3: extends }}{{4: with}} {{5:}}",

-- trait
["trait"] =
[[trait {{1:name}}{{2: extends }}{{3: with}} {
	{{4:}}
}
{{9}}
]],

-- class with trait Ordered(page 265)
["ordered"] =
[[class {{1:name}}{{2:(arg)}} extends Ordered[{{1}}] {{3: with}} {
	{{4:override def toString = "{{1}}"}}
	def compare(that: {{1}}) = {{5:this - that}}
	{{6}}
}
{{9}}
]],

-- case class
["casecl"] = "case class {{1:name}}{{2:(arg)}}{{3: extends }}{{4: with}} {{5:}}",

-- ###########################
--  testing
--
-- scalatest imports
["scalatest"] =
[[{{1:import org.scalatest.Suite}}
{{2:import org.scalatest.FunSuite}}
]],

-- assert
["assert"] = "assert({{1:a}} === {{2:b}})",

-- ensuring(p 296)
["ensuring"] = "ifel ensuring({{1:a}}=={{2:b}})",

-- expect
["expect"] =
[[expect({{1:what}}) {
	{{2}}
}
{{9}}
]],

-- intercept
["intercept"] =
[[intercept[{{1:IllegalArgumentException}}] {
	{{2}}
}
{{9}}
]],

-- test
["test"] =
[[test("{{1:description}}") {
	{{2}}
}
{{9}}
]],

-- suite
["suite"] =
[[class {{1}} extends Suite {
	def test() {
		{{2}}
	}
}
{{9}}
]],

-- funsuite
["fsuite"] =
[[class {{1:name}} extends FunSuite {
	test("{{2:description}}") {
		{{3}}
	}
}
{{9}}
]],

-- ###########################
--  SBT
--
["webproject"] =
[[import sbt._

class {{1:Name}}(info: ProjectInfo) extends DefaultWebProject(info) {
	val liftVersion = "{{2:2.3}}"

	override def libraryDependencies = Set(

	) ++ super.libraryDependencies

	val snapshots = ScalaToolsSnapshots
}
{{9}}
]],

-- depencies
["liftjar"] = '"net.liftweb" %% "{{0:lib}}" % liftVersion % "compile->default",',

["jettyjar"] = '"org.mortbay.jetty" % "jetty" % "{{0:version}}" % "test->default",',

-- ###########################
--  Lift
--
-- lift imports
["liftimports"] =
[[import _root_.net.liftweb.http._
import S._
import _root_.net.liftweb.util._
import Helpers._
import _root_.scala.xml._
]],

-- TODO LIFT,SBT,WEB.XML,HTML snippets
}
