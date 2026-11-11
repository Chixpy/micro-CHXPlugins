# CHXTemplates micro plugin

`micro` plugin to insert code templates.

It provides some lua functions.

  - `lua:CHXTemplates.CHXTypeTemplate` (or `CHXTypeTemplate` command)
      - Inserts a template based on the selection, the word where cursor is  or
        the word at its left. Templates  availables depends on the FileType  or
        file extension if unknown
  - `lua:CHXTemplates.CHXGlobalTemplate` (or `CHXGlobalTemplate` command)
      - Inserts a template based on the selection, the word where cursor is  or
        the word at its left. Templates are global for any file.
  - `lua:CHXTemplates.CHXNextPH` (or `CHXTypeTemplate` command)
      - Moves cursor to next template placeholder or return to first one.
  - `lua:CHXTemplates.CHXListTypeTemplates` (or `CHXListTypeTemplates` command)
      - Opens an  HSplit  with a  list  of posible  template  keywords for  the
        current FileType.
  - `lua:CHXTemplates.CHXListGlobalTemplates`   (or    `CHXListGlobalTemplates`
    command)
      - Opens an HSplit  with a list  of posible  keywords of global  templates
        for the current file  wich **begin** with  selected text, the the  word
        where cursor is or the word at its left.

## Key Bindings

Default key bindings, if no already set:

  - `Alt-Shift-c`: Adds a FileType template, if fails add a global one.
  - `Alt-Shift-g`: Adds a global template, if fails add a FileType one.
  - `Alt-Shift-n`: Jumps to next placeholder of the last template added.
  - `Shift-F1`: Opens a splitted panel with acepted keywords for FileType.
  - `Ctrl-F1`: Opens a splited  with global keywords  wich begin with  selected
    text.

You can easily modify that in your `bindings.json` file by adding:

```json
{
  "Alt-C": "lua:CHXTemplates.CHXTypeTemplate|lua:CHXTemplates.CHXGlobalTemplate",
  "Alt-G": "lua:CHXTemplates.CHXGlobalTemplate|lua:CHXTemplates.CHXTypeTemplate",
  "Alt-N": "lua:CHXTemplates.CHXNextPH",
  "Shift-F1": "lua:CHXTemplates.CHXListTypeTemplates",
  "Ctrl-F1": "lua:CHXTemplates.CHXListGlobalTemplates",
}
```

## But there is an official "snippets" plugin...

Yes, but I prefered make another plugin than fixing its bugs:

  - Using non  ASCII  characters in  snippets or  placeholders  is not  handled
    correctly with a mismatched placeholder position.
  - Writting a non ASCII  char in a placeholder  can show wrong characters  and
    finally can crash `micro`.
  - If a placeholder has a default  text, only works correctly if it's  defined
    in the last position of the repeated placeholder.
  - Not a bug,  but a misundertand.  Placeholders are  not followed in  defined
    numeric order, wich can be confusing when making a snippet.

## This works a little different...

`snippets` works  internally with the  text inside  placeholders updating  them
with the current size, synchronizing placeholders, autoselecting, etc.

`CHXTemplates` simply jumps  to a  placeholder and spawns  multicursors if  the
placeholder number is repeated in other locations.

## Some downsides by design

Nothing better than begin with the downsides of this plugin ;-)

  - It don't ask for a template name if cursor is not over nor after a word.
  - Current template  text is  not monitorized,  so  it cannot  be canceled  or
    deleted with a single command.
  - Template  file format  is  actually lua  code  returning a  table/map  with
    multiline strings. No parse is needed this way but it's format can be  more
    confusing.
  - Non alphanumeric template  keywords are  limited to one  character or  must
    have to be selected by hand.
  - **Remember** to  remove multicursors  with  `Alt-c`, its  like accepting  a
    template in `snippets`.

## Now, some improvements

  - As there is not an actual  internal processing (except moving the  cursors'
    placeholder positions)  of the  text, UTF8 characters  don't have  to be  a
    problem or crash `micro`.
  - Indent is preserved  when adding multiline templates  and current tab  mode
    in the buffer is preserved too.
  - There is not need  to _accept_ the template  when editimg is finished,  but
    **remember** to  cancel multicursors when  done. Jumping  to another  place
    holder will remove previously created one, obviously.
  - Placeholders are  kept  until a  new template  is added.  So,  they can  be
    jumped to at any time.
  - Other little details  derived from  string handling without  UTF8 runes  in
    mind wich causes problems in `snippets`.
  - Jumping to placeholder is  done in numeric order  and ids can skip  numbers
    (so, you don't need to change all  numbers if a placeholder is deleted  and
    can intentionally skip numeration to let to add more between them).
  - Althought it is in downsides, template file format is actually code so  you
    can actually  do  magic with  templates  like creating  a  `case` with  any
    number of options dinamically.
  - `CHXList[x]Templates` opens  a new  buffer with  the list  of keywords  for
    templates and a little previsualization.
  - There are two types of templates:
      - Global that can be used at any time for any file type.
      - Filetype specific.
  - Template files are called  when a template is  added. They can be  modified
    and changes work.
  - Global templates are  splitted in several files  using the first  character
    of the  keyword as  filename, so you  don't need  to wait  loading all  the
    global templates (more  than 2400 are the  symbols from `jlabbrev`  plugin)
    to add one.
  - So, yes,  after version 1.1.0,  this plugin  its an mix  of `snippets`  and
    `jlabbrev` plugins.
    
## Things I will not fix. Call it bugs

On repeated placeholders:

  - Only first default text  found will be  used, other different default  text
    on placeholders with same id number will be ignored.
  - If the first  appareance of a placeholder  has not a  default text and  any
    other placeholder sets  it, it will  not update first  ones and later  will
    have the default text. It doesn't have a recursive algorithm.
  - If, by edition, a placeholder overlaps any additional cursor, they can  not
    be separated again. It adds complexity to algorithm for such rare case.

Now a weird one, not sure if a bug, I don't understand, very annoying:

If main plugin source  file is changed, saved  and reloaded; testing it  inside
it (trying to add  a template or  open the lua template  keyword list) it  will
run "half" updated code and values. It's difficult to explain. For example,  if
the format  of the keyword  list buffer  is changed (headers  and the  template
list),  saved and  reloaded,  trying  to open  it  (to  show the  lua  template
keywords) can show the  headers with previous old  format and the keyword  list
in the new. Changing to other panel and opening the list and it work well.

This situation is  crazy developing with onBeforeTextEvent  and have an  error,
if you fix it and errors will continue.

**So, Don't test the plugin changes in the source code panel.**
