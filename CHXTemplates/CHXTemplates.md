# CHXTemplates micro plugin

`micro` plugin to insert code templates.

It provides some Lua functions.

- `lua:CHXTemplates.CHXTypeTemplate` (or `CHXTypeTemplate` command)
    - Inserts a template based on the selection, the word where the cursor is
      or the word to its left. Available templates depend on the FileType or
      file extension if unknown.
- `lua:CHXTemplates.CHXGlobalTemplate` (or `CHXGlobalTemplate` command)
    - Inserts a template based on the selection, the word where the cursor is
      or the word to its left. Templates are global for any file.
- `lua:CHXTemplates.CHXNextPH` (or `CHXNextPH` command)
    - Moves the cursor to the next template placeholder or returns to the
      first one.
- `lua:CHXTemplates.CHXListTypeTemplates` (or `CHXListTypeTemplates` command)
    - Opens an HSplit with a list of possible template keywords for the
      current FileType.
- `lua:CHXTemplates.CHXListGlobalTemplates` (or `CHXListGlobalTemplates`
  command)
    - Opens an HSplit with a list of possible keywords of global templates for
      the current file which **begin** with the selected text, the word where
      the cursor is or the word to its left.

## Key Bindings

Default key bindings, if not already set:

- `Alt-Shift-c`: Adds a FileType template; if that fails, adds a global one.
- `Alt-Shift-g`: Adds a global template; if that fails, adds a FileType one.
- `Alt-Shift-n`: Jumps to the next placeholder of the last template added.
- `Shift-F1`: Opens a split panel with accepted keywords for the FileType.
- `Ctrl-F1`: Opens a split panel with global keywords which begin with the
  selected text.

You can easily modify them in your `bindings.json` file by adding:

```json
{
  "Alt-C": "lua:CHXTemplates.CHXTypeTemplate|lua:CHXTemplates.CHXGlobalTemplate",
  "Alt-G": "lua:CHXTemplates.CHXGlobalTemplate|lua:CHXTemplates.CHXTypeTemplate",
  "Alt-N": "lua:CHXTemplates.CHXNextPH",
  "Shift-F1": "lua:CHXTemplates.CHXListTypeTemplates",
  "Ctrl-F1": "lua:CHXTemplates.CHXListGlobalTemplates"
}
```

## But there is an official "snippets" plugin...

Yes, but I preferred making another plugin rather than fixing its bugs:

- Using non-ASCII characters in snippets or placeholders is not handled
  correctly, with mismatched placeholder positions.
- Writing a non-ASCII character in a placeholder can show wrong characters and
  can eventually crash `micro`.
- If a placeholder has a default text, it only works correctly if it's defined
  in the last position of the repeated placeholder.
- Not a bug, but a misunderstanding. Placeholders are not followed in the
  defined numeric order, which can be confusing when making a snippet.

## This works a little differently...

`snippets` works internally with the text inside placeholders, updating them
with the current size, synchronizing placeholders, autoselecting, etc.

`CHXTemplates` simply jumps to a placeholder and spawns multiple cursors if the
placeholder number is repeated in other locations.

## Some downsides by design

Nothing better than beginning with the downsides of this plugin ;-)

- It doesn't ask for a template name if the cursor is neither over nor after a
  word.
- Current template text is not monitored, so it cannot be canceled or
  deleted with a single command.
- Template file format is actually Lua code returning a table/map with
  multiline strings. No parsing is needed this way, but its format can be more
  confusing.
- Non-alphanumeric template keywords are limited to one character or must be
  selected by hand.
- **Remember** to remove multicursors with `Alt-c`, it's like accepting a
  template in `snippets`.

## Now, some improvements

- As there is no actual internal processing of the text (except moving the
  cursors' placeholder positions), UTF-8 characters are not a problem and do
  not crash `micro`.
- Indentation is preserved when adding multiline templates, and the current tab
  mode in the buffer is preserved too.
- There is no need to _accept_ the template when editing is finished, but
  **remember** to cancel multicursors when done. Jumping to another
  placeholder will remove the previously created ones, obviously.
- Placeholders are kept until a new template is added. So, they can be jumped
  to at any time.
- Other little details derived from string handling without UTF-8 runes in
  mind, which cause problems in `snippets`.
- Jumping to a placeholder is done in numeric order and IDs can skip numbers
  (so you don't need to change all numbers if a placeholder is deleted and
  can intentionally skip numbering to allow adding more between them).
- Although it is listed among the downsides, template file format is actually
  code, so you can actually do magic with templates, like creating a `case`
  with any number of options dynamically.
- `CHXList[x]Templates` opens a new buffer with the list of keywords for
  templates and a little preview.
- There are two types of templates:
    - Global templates that can be used at any time for any file type.
    - Filetype-specific templates.
- Template files are loaded when a template is added. They can be modified and
  the changes take effect.
- Global templates are split into several files using the first character of
  the keyword as the filename, so you don't need to wait for all the global
  templates to load (more than 2400 symbols come from the `jlabbrev` plugin)
  to insert one.
- So, yes, after version 1.1.0, this plugin is a mix of `snippets` and
  `jlabbrev` plugins.
    
## Things I will not fix. Call them bugs

On repeated placeholders:

- Only the first default text found will be used; other default texts on
  placeholders with the same ID number will be ignored.
- If the first appearance of a placeholder does not have a default text but a
  later one sets it, the first ones will not be updated; only the later ones
  will have the default text. The algorithm is not recursive.
- If, while editing, a placeholder overlaps another cursor, they cannot be
  separated again. It would add complexity to the algorithm for such a rare
  case.
  
Now a weird one: not sure if it is a bug, I don't understand it, very annoying:

If the main plugin source file is changed, saved and reloaded, testing it
inside it (trying to add a template or open the Lua template keyword list) will
run "half" updated code and values. It's difficult to explain. For example, if
the format of the keyword list buffer is changed (headers and the template
list), saved and reloaded, trying to open it (to show the Lua template
keywords) can show the headers in the previous old format and the keyword list
in the new one. Changing to another panel and opening the list again works
well.

This situation is crazy when developing with `onBeforeTextEvent` and having an
error: if you fix it, the errors will continue.

**So, don't test plugin changes in the source code panel.**
