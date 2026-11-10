-- Templates of SQL for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

return {

["tbl"] =
[[
create table {{1:Table}} (
	{{2:col}}
);
{{9}}
]],

["col"] = "{{1:name}}	{{2:type}}	{{3:default ''}}	{{4:not null}}",

["ccol"] = "{{1:name}}	varchar2({{2:size}})	{{3:default ''}}	{{4:not null}}",

["ncol"] = "{{1:name}}	number	{{3:default 0}}	{{4:not null}}",

["dcol"] = "{{1:name}}	date	{{3:default sysdate}}	{{4:not null}}",

["ind"] = "create index {{0:$1_$2}} on {{1:table}}({{2:column}});",

["uind"] = "create unique index {{1:name}} on {{2:table}}({{4:column}});",

["tblcom"] = "comment on table {{1:table}} is '{{2:comment}}';",

["colcom"] = "comment on column {{1:table}}.{{2:column}} is '{{3:comment}}';",

["addcol"] = "alter table {{1:table}} add ({{2:column}} {{3:type}});",

["seq"] = "create sequence {{1:name}} start with {{2:1}} increment by {{3:1}} minvalue {{4:1}};",

["s*"] = "select * from {{1:table}}",
}
