- `CHXFPCCheck`: Updating version, removing search in source file directory
  because its added by default.
- Changed `org.md` of `cheat` plugin... Not very useful to have a cheat sheet
  of eMacs shortcuts in `micro` (And sincerely I like _Org-Mode_ more than
  _Markdown_).
- Modified `pascal.snippets`, plugin has some unexpected quirks and fixing
  properties shortcuts.
- `syntax/pascal.yaml`:
  - Changing generalization of types by context.
  - Fixing some `if`/`while`/`repeat` and logical comparisons of variables.
  - Added type color for `[procedure|function|operator] aType.MethodName`.
  - Added type color for `[specialize|generic] aType`. (Although I think is
    redundant).
  - Ops, fixing highlight of `Format` arguments inside a string `' '` instead
    inside a char `" "`. Lol.
  - Added some keywords.
  - Better `asm`-`end` detection.
  - Char by ASCII (`#15`) no longer color to the end of line.
