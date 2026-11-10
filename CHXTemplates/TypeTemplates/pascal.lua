-- Templates of CHX text style for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

-- Templates are very verbose (with begin..end) and many sections.
-- If something is not needed, just delete it.

-- I thinked using templates that writes shortcuts to another ones, but I
-- prefered to keep it simple.

local templates = {

-------- File structure
["File structure"] = "", -- Header for help file

---- Program structure
["program"] =
[[program {{1}};
{< Program {{1}}

	(c) {{2:20}} {{3}} https://{{4:github.com/}}
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}

uses

const

resourcestring

type

{
	{{1}} Main Program
}
var

begin
	{{5}}
end.
]],

---- Unit (generic)
["unit"] =
[[unit u{{1}};
{< Unit of {{2}}

	(c) {{3:20}} {{4}} https://{{5:github.com/}}
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}

interface

uses

const

resourcestring

type
  {{6}}

implementation

initialization

finalization

end.
]],

---- Unit (Class)
["unitc"] =
[[unit uc{{1}};
{< Unit of c{{1}} class.

	(c) {{2:20}} {{3}} https://{{4:github.com/}}
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}

interface

uses
	Generics.Collections;

const

resourcestring

type

{
	c{{1}}
}

	c{{1}} = class ({{5:tObject}})
	private

	protected

	public

		constructor Create;
		destructor Destroy; override;

	end;

	c{{1}}GenList = specialize tObjectList<c{{1}}>;
	c{{1}}List = class(c{{1}}GenList);

implementation

{
	c{{1}}
}

constructor c{{1}}.Create;
begin
	inherited Create;
end;

destructor c{{1}}.Destroy;
begin
	inherited Destroy;
end;

initialization

finalization

end.
]],

---- Unit (Record)
["unitr"] =
[[unit ut{{1}};
{< Unit of t{{1}}.

	(c) {{2:20}} {{3}} https://{{4:github.com/}}
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
{$MODESWITCH AdvancedRecords}
{$MODESWITCH TypeHelpers}

interface

uses
	Generics.Collections;

const

resourcestring

type

{
	t{{1}}
}

	t{{1}} = {{5}} record
	public
		procedure Init;
	end;

	p{{1}} = ^t{{1}};

	c{{1}}GenList = specialize tList<c{{1}}>;
	c{{1}}List = class(c{{1}}GenList);

implementation

{
	t{{1}}
}

procedure t{{1}}.Init;
begin

end;

initialization

finalization

end.
]],

-------- Implementation code blocks
["Implementation code blocks"] = "", -- Header for help file

---- begin..end block.
["b"] =
[[begin
	{{1}}
end;
{{9}}]],

---- Case

-- Actually they are created dynamically with "case<NCases>" and "caseb<NCases>"
-- These are only a help of dynamic templates when listing.
["case<NCases>"] =
[[case {{1}} of
{{2}} : {{3}}
[...]

otherwise // case {{1}}

end; // case {{1}}
{{9}}]],

["caseb<NCases>"] =
[[case {{1}} of
{{2}} :
begin
	{{3}}
end;

[...]

otherwise // case {{1}}

end; // case {{1}}
{{9}}]],

---- constructor
["cons"] =
[[constructor c{{1}}.Create(const {{2}} : {{3}});
begin
	inherited Create;
	{{4}}
end;
{{9}}]],

---- destructor
["dest"] =
[[destructor c{{1}}.Destroy;
begin
	{{2}}
	inherited Destroy;
end;
{{9}}]],

---- for..to
["for"] =
[[for {{1}} := {{2:0}} to {{3:High()}} do
begin
	aItem := {{4}}[{{1}}];
	{{5}}
end;
{{9}}]],

---- for..downto
["ford"] =
[[for {{1}} := {{2:High()}} downto {{3:0}} do
begin
	aItem := {{4}}[{{1}}];
	{{5}}
end;
{{9}}]],

---- for..in
["forin"] =
[[for {{1}} in {{2}} do
begin
	{{3}}
end;
{{9}}]],

---- function
["func"] =
[[function {{1}}(const {{2}} : {{3}}) : {{4}};
begin
	{{5}}
	Result := {{6}}
end;
{{9}}]],

---- if
["if"] =
[[if ({{1}}) then
begin
	{{2}}
end; // if {{1}}
{{9}}]],

---- if..else
["ife"] =
[[if ({{1}}) then
begin
	{{2}}
end
else // not {{1}}
begin
	{{3}}
end; // if {{1}}
{{9}}]],

---- if -> Exit
["ifx"] =
[[if ({{1}}) then
	Exit({{2}});
{{9}}]],

---- operator
["oper"] =
[[operator {{1}}(const {{2}}1, {{2}}2 : {{3}}) : {{4}};
begin
	Result := {{5}};
end;
{{9}}]],

---- procedure
["proc"] =
[[procedure {{1}}(const {{2}} : {{3}});
begin
	{{4}}
end;
{{9}}]],

---- repeat..until
["repeat"] =
[[repeat
	{{1}}
until {{2}};
{{9}}]],

---- Create -> try..finally & Free
["tryc"] =
[[{{1}} := c{{2}}.Create;
try
	{{3}}
finally
	{{1}}.Free;
end;
{{9}}]],

---- try..except
["trye"] =
[[try
	{{1}}
except
	on E : {{2}} do
	begin
		{{3}}
	end;
end;
{{9}}]],

---- try..finally
["tryf"] =
[[try
	{{1}}
finally
	{{2}}
end;
{{9}}]],

---- try..except..finally
["tryef"] =
[[try
	try
		{{1}}
	except
		on E : {{2}} do
		begin
			{{3}}
		end;
	end;
finally
	{{4}}
end;
{{9}}]],

---- try..finally (Destroys exception objects)
["tryfe"] =
[[try
	{{1}}
finally
	try
	except // Destroys exceptions
	end;

	{{2}}
end;
{{9}}]],

---- while
["while"] =
[[while ({{1}}) do
begin
	{{2}}
end;
]],

---- with
["with"] =
[[with {{1}} do
begin
	{{2}}
end;
{{9}}]],

-------- Type Declarations
["Type declarations"] = "", -- Header for help file

---- Dynamic array.
["array"] = "{{1}}s = Array of {{2}};\n{{9}}",

---- Static array.
["arrays"] = "{{1}}s = Array[{{2}}..{{3}}] of {{4}};\n{{9}}",

---- Class
["class"] =
[[c{{1}} = class({{2:tObject}})
private

protected

public
	{{3}}

	constructor Create;
	destructor Destroy; override;
end;
{{9}}]],

---- Class of
["classof"] = "T{{1}}Class = class of c{{1}};\n{{9}}",


---- Record
["record"] =
[[t{{1}} = {{2:packed}} record
	{{3}}
end;
tp{{1}} = ^t{{1}};
{{9}}]],

---- Advanced Record
["arecord"] =
[[t{{1}} = {{2:packed}} record
public
	{{3}}

	procedure Init;
end;
tp{{1}} = ^t{{1}};
{{9}}]],

---- Record with variant part (and advanced)
["vrecord"] =
[[t{{1}} = {{2:packed}} record
public
	procedure Init;

	case Byte of
		0 : ({{3}}: {{4}});
		1 : ({{5}}: {{6}});
end;
tp{{1}} = ^t{{1}};
{{9}}]],

---- Specialization
["spec"] = "{{1}} = specialize {{2}}<{{3}}>;\n{{9}}",


-------- Miscellaneous Shortcuts
["Miscellaneous shortcuts"] = "", -- Header for help file

---- Default array property of a class
["propd"] = "property {{1}}[Index : {{2}}] : {{3}} read Get{{1}} write Set{{1}}; default;\n{{9}}",

---- Property read-only
["propr"] = "property {{1}} : {{2}} read Get{{1}};\n{{9}}",

---- Property read/write
["proprw"] = "property {{1}} : {{2}} read F{{1}} write Set{{1}};\n{{9}}",

---- Property write-only
["propw"] = "property {{1}} : {{2}} write Set{{1}};\n{{9}}",

---- Defines (and remove not needed)
["prepd"] = [[{$MODE ObjFPC}{$H+}{$INLINE ON}{$WARN 6058 OFF}
{$MODESWITCH AdvancedRecords}
{$MODESWITCH TypeHelpers}
]],

}

-------- Alias for templates

templates["Alias of previous templates"] = "" -- Header for help file

templates["begin"] = templates["b"]
templates["constructor"] = templates["cons"]
templates["destructor"] = templates["dest"]
templates["function"] = templates["func"]
templates["ifelse"] = templates["ife"]
templates["ifexit"] = templates["ifx"]
templates["operator"] = templates["oper"]
templates["procedure"] = templates["proc"]
templates["property"] = templates["propr"]

-------- Dynamic keyword templates

-- This way we can create dynamic templates: case<NCases> caseb<NCases>
setmetatable(templates, {
  __index = function(t, key)
    local parStr = ""

  -- "case<NCases>" without begin..end
    parStr = key:match("^case(%d+)$")
    if parStr then
      local n = tonumber(parStr)

      local lines = "case {{1}} of\n"
      for i = 1, n do
        local j = i * 2
        lines = lines .. "{{" .. j .. ":" .. i .. "}} : {{".. j + 1 .. "}}\n\n"
      end
      lines = lines .. "otherwise\n"
      lines = lines .. "\t{{" .. (n + 1) * 2 .. "}}\n"
      lines = lines .. "end;\n{{" .. (n + 1) * 3 .. "}}"
      return lines
    end

  -- "caseb<NCases>" with begin..end
    parStr = key:match("^caseb(%d+)$")
    if parStr then
      local n = tonumber(parStr)

      local lines = {}
      table.insert(lines, "case {{1}} of")
      for i = 1, n do  -- Dynamic number of cases
        local j = i * 2
        table.insert(lines, "{{" .. j .. ":" .. i .. "}} :")
        table.insert(lines, "begin")
        table.insert(lines, "\t{{".. j + 1 .. "}}")
        table.insert(lines, "end;")
        table.insert(lines, "")
      end
      table.insert(lines, "otherwise")
      table.insert(lines, "\t{{" .. (n + 1) * 2 .. "}}")
      table.insert(lines, "end;")
      table.insert(lines, "{{" .. (n + 1) * 3 .. "}}")

      return table.concat(lines, "\n")
    end

    -- -- For other keywords
    -- local parStr = key:match("^keyword(%d+)$")
    -- if parStr then
    --   Make an string
    --   return str
    -- end
    return nil
  end
})

return templates
