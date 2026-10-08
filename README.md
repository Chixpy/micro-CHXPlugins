# micro-CHXPlugins

Plugins for `micro` editor.


## `0Config` directory

Well, this directory is not a plugin. It has some configuration and keybinding
examples and other useful files. They are structured as `.config/micro/`
directory is:

- `bindings.json`: Example `micro` key binding file, with key bindings for
  CHXPlugins. Althought plugins themselves try to bind the keys if they are not
  already binded.
- `settings.json`: Example `micro` settings file with some file type
  configurations and costumizations.

### `help` subdirectory

Files with some additional help. Initally, I wanted to do a plugin
wich added documents to `micro` help system, something similar to `cheat`
plugin; but I realized that copying them directly in `help` folder is easiest.

- `jlsymbols.md`: Cheatsheet of sorted abbreviations of `jlabbrev` plugin.
  But as the plugin itself has a little problem with some of them and it very
  slow open `micro` with it, I prefer to use `symbols.md` to copy-paste them.
- `symbols.md`: Document with symbols with tematic grouping for easy copying
  and pasting, mainly from `jlabbrev` plugin.

### `syntax` subdirectory

Subdirectory with syntax highlight files:

- `pascal.yaml`: Has some fixes from default one:
  - `*.[dpr|inc|lpr|p|pas|pp]` for Pascal files (Well, `.inc` is a personal
    preference).
  - Changed default comment to `//` for `comment` plugin. (This can be
    changed in `settings.json` too)
  - Fixed `{\n[...]}` comments.
  - Removed Special Char highlight for C like escape symbols in strings
    (like `\n`).
  - Added `TODO|FIXME|HACK|FIXED:` highlight in comments. `FIX:` in another
    color...
  - Adding highlight of PasDoc params in comments and simple Markdown syntax.
  - Grouping keyworks.
  - Highlight `Format` parameters in strings.

### `colorscheme` subdirectory

Here there is an example colorscheme file spliting interface and content.

## CHX Plugins

Some simple plugins that I created as needed.

### CHXFastSearch

Searches the next ocurrence of the word where cursor is (or selected text).

A poor implementation of "JumpToDeclaration/Implementation" as in Pascal
usually are in the same file.

### CHXSplitLines

Can split a line in two ways:

- Splits it at `colorcolumn` micro's setting (or 80 if not set).
- Splits at a char (wich is asked for) in current selection.

## Modified oficial plugins

Custom modifications of oficial plugins. Maybe if modifications get bigger
I will make a proper new plugin

### `jump`

- Fixed not showing what to line jumped.
- Show only Title/Function/Tag and line number in `fzf` menu.

### `quoter`

- Added `< >`, `¿ ?` and `¡ !`.

### `snippets`

- Added `pascal.snippets` file.
