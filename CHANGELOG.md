## 2026-10-25 18:45

- `syntax/pascal.yaml`: Added `and` as operator.
- `CHXSplitLines` plugin:
  - A little clean up.
  - Better support for UTF8 multibyte characters. So it doesn't split early.
  - `CHXSplitLines` function: Keep indent when spliting lines.
  - Added `CHXSplitLines.CHXJustifyLine`:  Justifies  (and  splits if needed) a
    line.
  - Added  `CHXSplitLines.CHXJustifyParagraph`:  Joins,  re-splits  (if needed)
    and justifies paragraphs separated by empty lines.

## 2026-10-17 21:18

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

## 2026-10-12 23:17

- Little documentation fixes.
- `CHXFPCCheck` plugin:
  - Use of `-s`, it generates `*.ppu` files.
  - Jump cursor to first Error/Fatal message. Not Warning, Note or Hint.
  - Adding a message at InfoBar when finished.
- Renamed `CHXFPCCheck/repo.json` to lower case...

## 2026-10-12 01:18

- Updating `README.md`.

## 2026-10-11 23:48

- Added `CHXFPCCheck` a proper check syntax for FreePascal (and a commented out
  configuration for internal `linter`.). Actually it's only need two steps to
  be a plugin to compile pascal programs.
- Changed color of tab errors and trailing spaces, I want it visible but not
  blow me eyes.
- Fixed `Alt-Shift-[x]` bindings, they don't work for me but `Alt-[X]` does.

## 2026-10-10 17:24

- Added `CHXStatusExt`. Adds some function for status bar.
- Fixes and modifications in other files.

## 2026-10-08 23:54

- Added WIP of `help/symbols.md` and `help/jlsymbols.md`.
- Added a little fix and modification of `jump` plugin.
- Added a little modification of `quoter` plugin.
- Added `snippets` file for Pascal language.
- Reworked `syntax/pascal.yaml`.
- Added an example `colorscheme/CHXdark.micro`

## 2026-10-04 00:22

- Adding `repo.json` of plugins.
- Adding `0Config` with a example configuration and other files.

## 2026-10-03 19:43

- Added `CHXFastSearch`.
- Added `CHXSplitLines`.
