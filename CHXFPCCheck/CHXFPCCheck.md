# CHXFPCCheck

`micro` plugin to check syntax for Free Pascal programs and units.

It provides the next lua function.

- `lua:CHXFPCCheck.CHXFPCCheck`
  - Check current pascal program syntax

Adding to internal linter is possible, and there is a commented out
configuration example in source code but there are some issues discused later.

## Key Bindings

Default key bindings, if no already set: `Alt-P` (`Alt` + `Shift` + `p`)

You can easily modify that in your `bindings.json` file by adding:

```json
{
    "Alt-P": "lua:CHXFPCCheck.CHXFPCCheck",
}
```

## Adding to default micro linter

Adding Free Pascal to internal `micro` linter can be as easy as...

```
linter.makeLinter("fpc", "pascal", "fpc", {"-v0ewnh", "%f"}, "%f%(%l,%c%) %m")
```

With `-v[...]` parameter, verbosity, can be customized a little more:

- `0`: Remove many default info messages, so less lines to parse.
- `e`: Shows errors (activated by default, with `0` too).
- `w`: Shows warnings (generally are useful).
- `n`: Show notes (generally are less useful).
- `h`: Show hints (What the tin says).

So, `"-v0ewnh"` will show all messages and they will be added to the buffer if
they are for current file. 

### But is not a syntax check...

It will try to compile, generating object files `*.o`, `*.ppu` and executable
one on compilation success.

`fpc` has not a _Syntax Check_ option _per se_. The only near options are:

- `-s`: Don't assemble nor link.
  - It creates an assembler file `[FileName].s` (and `[FileName].ppu`) at
    source file directory.
  - It creates `link.res` and `ppas.sh` (in Linux) an working directory.
  - Not sure if source files are not changed, and it founds previous files it
    don't recompile them.
- `-Cn`: Assemble but skip linker.
  - It creates `[FileName].o` at source file directory.
  - If source files are not changed, and it founds previous files it don't
    recompile them.

Seems that `-s` it's faster and generates `*.ppu` files needed to don't try to
recompile them if not changed.

### ... it's a compilation

`fpc` will need to find all units used by current source file and it will try
to compile them before current file. Recursively with each one.

If at least one is not found or has errors, it can abort compilation without
even try current file text.

By default, units (and other files) are searched in:

1. Source file directory.
2. Current working directory.
3. `fpc` system and package directories.

If they are not there we need provide `fpc` where to find them, as it is not
common to use `Uses uUnit in 'OtherFolder/uUnit.pas';`.

As a parachute, we can add some other directories with various `-Fu` params:

- `-Fu[FileDir]/*`: Source file directory subdiretories.
- `-Fu[FileParentDir]/*` or `-Fu[FileDir]/../*`: Source file directory brothers.
- `-Fu./*`: Working directory subdiretories.
- `-Fu./../*`: Working directory brothers.

> **Note 1**: If directories relative to source file are added, we need to
> change `linter` configuration when changing current file in micro. AFAIK,
> this must be done removing and re-addin the linter with the new
> configuration, because makeLinter don't change a linter configuration if
> it's already created.

> **Note 2**: As `-Fu` is for units (and other files), `-Fi` is for include
> files but usually these are in same folder along the files that call them.
> If an include file is not found its directory must be added too

### Better use a config file if available

For more complex projects, previous configuration can be not enough. Units
are across many directories.

Surely, these projects will use a config file for `fpc` and we can add it with
their actual project configuration (unless Lazarus is used...).

This file contains command line arguments, one per line, with some
conditional features.

It can be done with a prompt or try to search it automatically, and it's added
with `@[File]` parameter.

> **Note 3**: As previous Note 1, if it's used then must be updated when
> current file changes.

> **Note 4**: If this parameter is added and the file is not found then `fpc`
> will return an error without trying to compile anything.

> **Warning Hint**: ***¡¡¡DON'T USE `fpc.cfg` AS FILENAME!!!*** Use another
> filename: `config.fpc`, `build.cfg` or `CowsAre.Blue`, but not ~~`fpc.cfg`~~.

### What about created files?

The easiest one, just change output dir with `-FU` (for `*.o`, `*.ppu`,
executable and others) and `-FE` (override for executable) to a temp dir.

Then we want to add the temporal folder with `-Fu` and it will find already
compiled units and it will not recompile them.

### The final config

1. Search a temporal directory for output and create it (`fpc` doesn't create
  directories; well, it can create only one level as much).
2. Get source file directory (It's not really needed to get its parent).
3. Get a fpc config file to add its configuration. If none is used don't add
  it's parameter.
4. Call `linter.makeLinter`:

```lua
function ConfigureInternalLinter(PasFile, TmpDir, CFGFile)

  linter.removeLinter("fpc")
 
  FileDir = filepath.Dir(PasFile)
  local Args = {
    "-s",                    -- "-s" = Don't Assemble or "-Cn" = Compile ".o"
    "-FU"..TmpDir,           -- Temp output dir for .o .ppu
    "-FE"..TmpDir,           -- Temp output dir for executable
    "-Fu"..TmpDir,           -- Search precompiled units in output dir
    "-Fu./*",                -- Search units in working directory subdirs.
    "-Fu../*",               -- Search units in working directory brothers.
    "-Fu"..FileDir.."/*",    -- Search units in souce file directory subdirs.
    "-Fu"..FileDir.."/../*", -- Search units in souce file directory brothers.
    "-v0ewnh",               -- "0" = Minimal verbosity; "e" = Error;
                             -- "w" = Warning; "n" = Note; "h" = Hint
    "-l-",                   -- Remove Name and copyright, less output lines
    PasFile                  -- Current source file path
  }
 
  if CFGFile ~= "" then
    table.insert(Args, 1, "@"..CFGFile) -- Config file, add only if used
  end
 
  -- `linter.makeLinter` Can have more parameters. See `help linter`
  linter.makeLinter("fpc", "pascal", "fpc", -- ID, filetype, executable
    Args, "%f%(%l,%c%) %m")                 -- Args, output line regex
end
```

> **Remember**: As said before, if config file or subdirectories and brothers
> of source file directory are added then `linter` configuration must be
> changed when current file is changed. But must be removed and then re-added.
> so, this function needs to be called at relevant events... before any Save
> action.

### Then, why you didn't use internal `linter`?

There are still some issues:

- As noted before, if we want to add source file subdirectories to unit search
  paths, we need to reconfigure `linter` configuration for every source file
  and other quirks. Because `linter` launch automatically on save.
- `linter` doesn't make difference between message types. Althougth `micro`
  supports them (_Error_, _Warning_, _Info_), all messages are treated as
  errors.
  - The main problem, I think, is that _File_, _Row_, _Col_ and _Message_ must
    appear in that order inside the _regex_ for lines.
  - `gcc` have message type between _Row_ and _Col_, supporting it may break
    other linters.
  - If it is added, `fpc` can output gcc-like messages with `-vr` argument.
  - So, the logic must be reworked to be more flexible.
- `linter` auto-runs on save file automatically, as `fpc` is actually
  compiling I don't think is a good idea. We can launch another compilation
  before a previous one ends, making a paradox, exploding the world and
  imploding the universe... or simply I don't like it.
- We need to listen any current tab change and update `linter`. While with
  this plugin it only do it on explicit call.
- Actually, I want to extend the funcionality of this plugin as discussed in
  later chapter.

_But, you can modify `linter` plugin..._ Shut up.

## So, How CHXFPCCheck works

Well, basically it does all commented steps in _Adding to default micro linter_ 
chapter.

- On Init: Search for a temp directory
- When executed:
  1. Checks if it's a Pascal file
  2. Gets current source config file or ask for one (only first time). Can be
    none, if left empty on prompt.
  3. Creates output dir if it doesn't exist.
  4. Retrives all other info needed.
  5. Runs `fpc`.
  6. Parses output text:
    1. Gets all error messages and group them by file. (FPC can reference
      previous compiled files). Assigning its type of message.
    2. Stores first Error or Fatal message found
    3. For every file in messages:
      - If already opened add its messages.
      - If not opened and has an actual Error or Fatal, open it in a new tab.
  7. Move cursor to the file and position of the first error message.

## Posible improvements

- A function to forgive an assigned config file.
- If a file is opened and we have messages for it, add them (Making them
  persistent).
- Add a mean to jump between message lines.
- Make it configurable on verbosity without editing the plugin source.
- Persistent fpc config files between sessions.
- Some warnings and hints are not as useful as others, add a way to custom
  remove them individually.
- Parse `Lazarus` config files...
- Making an actual compile (and execute?) plugin:
  - This time, we need to take care of working directory and change it to were
    config?/main? file is.
  - Don't override file output directories.
  - `fpc` doesn't autocreate output directories. We need to parse config file
    to search and create them...
