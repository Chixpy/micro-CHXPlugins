# CHXTemplates micro plugin

`micro` plugin to insert code templates.

It provides three lua functions.

- `lua:CHXTemplates.CHXInsTemp`
  - Inserts a template based on the selection, the word where cursor is or  the
    word at its left.
- `lua:CHXTemplates.CHXNextPH`
  - Moves cursor to next template placeholder or return to first one.
- `lua:CHXTemplates.CHXListTemplates`
  - Opens an HSplit with  a list of posible  template keywords for the  current
    file.

## Key Bindings

Default key bindings, if no already set:

- `Alt-Shift-c`: Adds template.
- `Alt-Shift-n`: Jumps to next placeholder.
- `Shift-F1`: Opens a Split with acepted keywords

You can easily modify that in your `bindings.json` file by adding:

```json
{
  "Alt-C": "lua:CHXTemplates.CHXInsTemp",
  "Alt-N": "lua:CHXTemplates.CHXNextPH",
  "Shift-F1": "lua:CHXTemplates.CHXListTemplates",
}
```

## But there is an official "snippets" plugin...

Yes, but I prefered make another plugin than fixing its bugs:

- Using  non ASCII  characters  in  snippets  or placeholders  is  not  handled
  correctly with a mismatched placeholder position.
- Writting a  non ASCII char  in a  placeholder can show  wrong characters  and
  finally can crash `micro`.
- If a placeholder has a default text, only works correctly if it's defined  in
  the last position of the repeated placeholder.
- Not a  bug, but  a misundertand. Placeholders  are not  followed in  defined
  numeric order, wich can be confusing when making a snippet.

## This works a little different...

`snippets` works  internally with the  text inside  placeholders updating  them
with the current size, synchronizing placeholders, etc.

`CHXTemplates` simply jumps  to a  placeholder and spawns  multicursors if  the
placeholder is repeated.

## Some downsides by design

- It don't ask for a template name if cursor is not over nor after a word.
- Current  template  text is  not  monitorized, so  it  cannot be  canceled  or
  deleted with a single command.
- Template  file  format  is  actually lua  code  returning  a  table/map  with
  multiline strings. No parse  is needed this way but  it's format can be  more
  confusing.
- Non alphanumeric template keywords are limited to one character.
- **Remember** to remove multicursors with `Alt-c`.

## Some improvements

- As there is not an actual  internal processing (except moving the cursor)  of
  the text, UTF8 characters must not be a problem or crash `micro`.
- Indent  is  preserved  when  adding  multiline  templates  and  tab  mode  is
  preserved too.
- There  is  not need  to  _accept_  the  template when  editimg  is  finished.
  Placeholders are kept until a new template is added. So can be jumped at  any
  time.
- Other little details derived from string handling without UTF8 runes in  mind
  wich causes problems in `snippets`.
- Jumping to  placeholder is  done in numeric  order and  ids can skip  numbers
  (so, you don't need to change al numbers if a placeholder is deleted and  can
  intentionally skip them to let to add more between them).
- Althought it is in  downsides, template file format  is actually code so  you
  can actually do magic with templates like creating a case with any number  of
  options dinamically.

## Things I will not fix. Call it bugs

- On repeated placeholders:
  - Only  first  default text  found  will be  used,  other different  text  on
    placeholders with same id number will be ignored.
  - If the first  appareance of a placeholder  has not a  default text and  any
    other set  it, it  will not  update  firsts ones  and later  will have  the
    default text. It's not a recursive algorithm.
  - If, by edition, a placeholder overlaps any additional cursor, they can  not
    be separated again. It add complexity to algorithm for such rare case. 
  
