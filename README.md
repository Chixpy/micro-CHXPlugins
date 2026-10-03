# micro-CHXPlugins

Plugins for `micro` editor.


## 0Config

Well, this directory is not a plugin. It has some configuration and keybinding
examples and other usefull files. They are structured as `.config/micro/`
directory is:

- `bindings.json`: Example `micro` key binding file, with key bindings for
  CHXPlugins. Althought plugins themselves try to bind the keys if they are not
  already binded.
- `settings.json`: Example `micro` settings file with some file type
  configurations.
- `syntax/`: Subdirectory with syntax highlight files:
  - `pascal.yaml`: Has some fixes from default one:
    - `*.[dpr|inc|lpr|p|pas|pp]` for Pascal files (Well, `.inc` is a personal
      preference).
    - Changed default comment to `//` for `comment` plugin. (This can be
      changed in `settings.json` too)
    - Fixing `{}` comments.
    - Removed Special Char hightlight for C like escape simbols in strings
      (`\n`).
    - Adding `TODO|FIXME|HACK|FIXED:` highlight in comments. `FIX:` in another
      color...
    - Adding highlight of PasDoc params and simple Markdown syntax.
    - It needs another little fixes improvements.

## CHXFastSearch

Searches the next ocurrence of the current word (or selected text).

## CHXSplitLines

Can split a line in two ways:

- Splits it at `colorcolumn` micro's setting (or 80).
- Splits when an asked char is encountered.
