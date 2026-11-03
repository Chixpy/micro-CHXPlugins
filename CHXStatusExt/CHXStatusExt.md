# CHXStatusExt

`micro` plugin to add more available info for status bar.

- `CHXStatusExt.AbsDir`: Absolute dir of the file.
- `CHXStatusExt.AbsPath`: Absolute path of the file.
- `CHXStatusExt.GitRelDir`: Relative file from file's git base directory.
  - If  it is  not  a  repository file  then  it's  the  nearly the  same  that
    `CHXStatusExt.WorkRelDir` (but shows parent directory name).
- `CHXStatusExt.microRelDir`: File directory as opened in `micro`.
- `CHXStatusExt.WorkRelDir`: Relative directory from working directory.
- `CHXStatusExt.Time`: Current time (updated only in events, not in real time).
- `CHXStatusExt.Date`: Current date (updated only in events).
- `CHXStatusExt.FileModifTime`: Time of first  not saved modification  (updated
  only in events).
- `CHXStatusExt.FileElapTime`: Time elapsed from  first not saved  modification
  (updated only in events).

As an extra, some lua functions are added:

- `lua:CHXStatusExt.CHXInsertDate` (or command `CHXInsertDate`)
  - Inserts current date (yyyy/mm/dd)
- `lua:CHXStatusExt.CHXInsertTime` (or command `CHXInsertTime`)
  - Inserts current hour (24h).
- `lua:CHXStatusExt.CHXInsertPath` (or command `CHXInsertPath`)
  - Inserts current file absolute path, and remove what you don't want.

## Usage

In  `~/.config/micro/settings.json`   configuration,   in  `statusformatl`   or
`statusformatr` options use `$(CHXStatusExt.[Function])`:

```json
{
  "statusformatl": "[...] $(CHXStatusExt.GitRelDir) [...]",
  "statusformatr": "[...] $(CHXStatusExt.FileElapTime) [...]",
}
```

## Key binding

Default key bindings for editing function, if no already set:

- `Alt-Shift-D`: `CHXInsertDate`
- `Alt-Shift-H`: `CHXInsertTime`
- `Alt-Shift-F`: `CHXInsertPath`

You can easily modify that in your `bindings.json` file by adding and changing:

```json
{
    "Alt-D": "CHXStatusExt.CHXInsertDate",
    "Alt-H": "CHXStatusExt.CHXInsertTime",
    "Alt-F": "CHXStatusExt.CHXInsertPath",
}
```

## ToDo

_Now empty_
