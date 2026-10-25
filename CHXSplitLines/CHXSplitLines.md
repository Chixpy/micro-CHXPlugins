# CHXSplitLines

`micro` plugin to split long lines.

It provides two lua functions.

- `lua:CHXSplitLines.CHXSplitLines` (or command `CHXSplitLines`)
  - Splits current line at `columncolor` setting or 80 if not set.
  - Keeps original line indentation for new created lines.
  - You can select various lines, it does NOT join them before splitting.
- `lua:CHXSplitLines.CHXSplitLinesAt` (or command `CHXSplitLinesAt`)
  - Splits current line (or selected text) at any character.
  - Character is prompted at command panel.
  - Split character is NOT deleted, it's kept at previous line.
- `lua:CHXSplitLines.CHXJustifyLine` (or command `CHXJustifyLine`)
  - Justifies at both sides (and splits if needed) a line (o selected ones).
  - If the line is not splitted in the proccess, it will justify it.
  - If  the line is splitted,  the all resulting lines will be justified except
    last one.
  - **Warning**: It is not aware of context  (for example, in a list can insert
    extra spaces between the bullet and the first word or inside inline code).
- `lua:CHXSplitLines.CHXJustifyParagraph` (or command `CHXJustifyParagraph`)
  - Justifies  (and  splits  if needed) a  paragraph (as in _LML_ text formats,
    empty  line  separated)  at  both sides. Last line of the paragraph is ketp
    left.
  - Many paragraphs can be selected simultaneausly.  Not needed to select whole
    paragraphs.
  - It keeps indentation of the first line.
  - **Warning**:  It  automatically  searchs   paragraph  start  and  ending by
    searching  empty  lines  and  joinning before the lines. It is not aware of
    context (for example, a list or inline code).

## Key Bindings

Default key bindings, if no already set:

- `Alt-s`: CHXSplitLines
- `Alt-a`: CHXSplitLinesAt
- `Alt-Shift-J`: CHXJustifyParagraph
- `Alt-Shift-S`: CHXJustifyLine

You can easily modify that in your `bindings.json` file by adding and changing:

```json
{
    "Alt-s": "CHXSplitLines.CHXSplitLines",
    "Alt-a": "CHXSplitLines.CHXSplitLinesAt",
    "Alt-S": "CHXSplitLines.CHXJustifyLine",
    "Alt-J": "CHXSplitLines.CHXJustifyParagraph",
}
```

## Posible improvements

- Choose between hard wrap and soft wrap.
- Center  and  Right  aligned  paragraphs.  May be, but these will  remove text
  indent if used.
- Autowrap / justify while writing. Meh...
