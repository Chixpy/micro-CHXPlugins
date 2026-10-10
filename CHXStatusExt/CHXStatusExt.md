# CHXStatusExt

`micro` plugin to add more available info for status bar.

- `CHXStatusExt.AbsDir`: Absolute dir of the file.
- `CHXStatusExt.AbsPath`: Absolute path of the file.
- `CHXStatusExt.GitRelDir`: Relative file from file's git base directory.
  - If it is not a repository file then it's the nearly the same that
    `CHXStatusExt.WorkRelDir` (but shows parent directory name).
- `CHXStatusExt.microRelDir`: File dir as opened in `micro`.
- `CHXStatusExt.WorkRelDir`: Relative directory from working directory.
- `CHXStatusExt.Time`: Current time (updated only in events).
- `CHXStatusExt.Date`: Current date (updated only in events).
- `CHXStatusExt.FileModifTime`: Time of first not saved modification
  (updated only in events).
- `CHXStatusExt.FileElapTime`: Time elapsed from first not saved modification
  (updated only in events).

## Usage

In `~/.config/micro/settings.json` configuration, in `statusformatl` or
`statusformatr` options with `$(CHXStatusExt.[Function])`:

```json
{
  "statusformatl": "[...] $(CHXStatusExt.AbsDir) [...]",
  "statusformatr": "[...] $(CHXStatusExt.FileElapTime) [...]",
}
```
