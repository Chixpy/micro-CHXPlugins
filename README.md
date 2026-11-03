# micro-CHXPlugins

Plugins for _micro_ editor and some other useful files.

## [0Config](0Config) directory

Well, this directory is not a plugin. It has some configuration and  keybinding
examples  and other  useful  files.  They  are structured  as  `.config/micro/`
directory is:

- [bindings.json](0Config/bindings.json):  Example _micro_  key  binding  file,
  with key bindings  for CHXPlugins. Although, plugins  themselves try to  bind
  the keys if they are not already binded.
  
- [settings.json](0Config/settings.json): Example _micro_ settings file with
  some file type configurations and customizations. Uses `CHXStatusExt` plugin.

### [help](0Config/help) subdirectory

Files with some additional help. Initally, I  wanted to do a plugin wich  added
documents to _micro_ help  system, something similar  to _cheat_ plugin; but  I
realized that copying them directly in `help` folder is easiest.

- [jlsymbols.md](0Config/help/jlsymbols.md):     Cheatsheet      of      sorted
  abbreviations of _jlabbrev_  plugin. But as  the plugin  itself has a  little
  problem with some of them and it very slow open _micro_ with it, I prefer  to
  use `symbols.md` to copy-paste them.
- [symbols.md](0Config/help/symbols.md):  Document with  symbols  with  tematic
  grouping for easy copying and pasting, from _jlabbrev_ plugin and other ones.
- [symfont.md](0Config/help/symfont.md):   Other   language   characters    and
  matematical taxt fonts. 

### [syntax](0Config/syntax) subdirectory

Subdirectory with syntax highlight files:

- [CHXText.yaml](0Config/syntax/CHXText.yaml):  A custom  _.txt_  file  format,
  you can  call it  an LML.  But there is  not a  render program  nor a  _HTML_
  conversor.
- [pascal.yaml](0Config/syntax/pascal.yaml):  A   whole  restructuration   from
  default one:
  - `*.[dpr|inc|lpr|p|pas|pp]` for  Pascal files  (Well, _.inc_  is a  personal
    preference).
  - Changed default comment to `//` for `comment` plugin. (This can be  changed
    in `settings.json` too)
  - Fixed not recongnized `{\n[...]}` comments.
  - Removed Special Char highlight for  C like escape symbols in strings  (like
    `\n`, `\t`, etc.).
  - Added  `TODO|FIXME|HACK|FIXED:` highlight  in comments.  `FIX:` in  another
    color...
  - Adding highlight of PasDoc params in comments and simple Markdown syntax.
  - Keywords grouped by function... (but some of them can have many uses)
  - Highlight for `Format` parameters (like `%1:1.2d`) in strings.
  - Try to recognize all types by context instead only keyword types.

A rainbow festival at least.

### [colorscheme](0Config/colorscheme) subdirectory

Here there  is  an example  colorscheme file,  spliting  interface and  content
colors.

- [CHXDark.micro](0Config/colorscheme/CHXDark.micro):  Dark  theme.  Grey  text
  over _light_ black, Yellow highlight, dark grey comments, green keywords  and
  blue types.

## CHX Plugins

Some simple plugins that I created as needed.

### _CHXFastSearch_

> [Main documentation](CHXFastSearch/CHXFastSearch.md)

Searches the next ocurrence of the word where cursor is (or selected text).

It's a poor implementation  of "JumpToDeclaration/Implementation" as in  Pascal
usually are in the same file.

### _CHXFPCCheck_

> [Main documentation](CHXFPCCheck/CHXFPCCheck.md)

Free Pascal linter for pascal files.

Better to see its [documentation](CHXFPCCheck/CHXFPCCheck.md) than describe  it
here.

### _CHXSplitLines_

> [Main documentation](CHXSplitLines/CHXSplitLines.md)

Plugin that can split a line in some ways:

- Splits it at `colorcolumn` micro's setting (or 80 if not set).
- Splits at a char (wich is asked for) in current selection.
- Splits it justifying the text at right marging too.
- Justify a whole paragraph (delimited with empty lines).

Adds a function to _easyly_ write a  non breaking space wich can be used  where
spaces don't be added while justifying or don't let split a line there,

### _CHXStatusExt_

> [Main documentation](CHXStatusExt/CHXStatusExt.md)

Plugin to add more available info for status bar.

- File absolute path, even when opened as relative to current directory.
- File directory: Absolute, as opened  in micro, relative to working  directory
  or relative to its git repository.
- Time,  Date, _Timestamp  of first not  saved modification_  and Time  elapsed
  without saving.

### _CHXTemplates_

> [Main documentation](CHXTemplates/CHXTemplates.md)

Plugin to add text from templates. Created after some _snippets_ UTF8  problems
and with other features in mind.

## Modified oficial plugins

Custom modifications of oficial plugins. Maybe if modifications get bigger
I will make a proper new plugin.

### _jump_

- Fixed not showing to what line jumped.
- Show only Title/Function/Tag and line number in `fzf` menu.
- Use full file path. 

### _quoter_

- Added `< >`, `¿ ?` and `¡ !`.

### _snippets_

> No longer used after _CHXTemplates_ created
- Added [pascal.snippets](snippets/snippets/pascal.snippets) file.
- Added [CHXText.snippets](snippets/snippets/CHXText.snippets) file.
