# CHXFastSearch

`micro` plugin to fast search current word (or selection).

It provides two lua functions.

- `lua:CHXFastSearch.CHXPrevWord`
  - Search for previous ocurrence of the word (or selection) where cursor is at.
- `lua:CHXFastSearch.CHXNextWord`
  - Search for next ocurrence of the word (or selection) where cursor is at.

> **Note**: This functions change last search made with [Ctrl-F], so
> [Ctrl-N] and [Ctrl-P] will search for last word used with the scripts.

## Key Bindings

Default key bindings, if no already set:

- `Alt-k`: CHXPrevWord
- `Alt-l`: CHXNextWord

You can easily modify that in your `bindings.json` file by adding:

```json
{
    "Alt-k": "lua:CHXFastSearch.CHXPrevWord",
    "Alt-l": "lua:CHXFastSearch.CHXNextWord",
}
```
