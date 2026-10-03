# CHXSplitLines

`micro` plugin to split long lines.

It provides two lua functions.

- `lua:CHXSplitLines.CHXSplitLines` (or command `CHXSplitLines`)
  - Splits current line at `columncolor` setting or 80 if not set.
  - You can select various lines.
- `lua:CHXSplitLines.CHXSplitLinesAt` (or command `CHXSplitLinesAt`)
  - Splits current line (or selection) at any char ("," for example)

## Key Bindings

Default key bindings, if no already set:

- `Alt-s`: CHXSplitLines
- `Alt-a`: CHXSplitLinesAt

You can easily modify that in your `bindings.json` file by adding and changing:

```json
{
    "Alt-s": "CHXSplitLines.CHXSplitLines",
    "Alt-a": "CHXSplitLines.CHXSplitLinesAt",
}
```
