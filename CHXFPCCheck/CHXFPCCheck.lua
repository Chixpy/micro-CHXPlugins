VERSION = "1.0.0"

local filepath = import("filepath")
local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local buffer = import("micro/buffer")

local fpcCacheDir = ""
local FPCcfg = {}

function init()
  fpcCacheDir = os.getenv("TMPDIR")
  if fpcCacheDir == "" then
    fpcCacheDir = os.getenv("HOME") .. "/tmp"
  end
  fpcCacheDir = fpcCacheDir .. "/fpc_cache_micro"

  config.MakeCommand("CHXFPCCheck", CHXFPCCheck, config.NoComplete)
  config.TryBindKey("Alt-P", "lua:CHXFPCCheck.CHXFPCCheck", false)
  config.AddRuntimeFile("CHXFPCCheck", config.RTHelp, "CHXFPCCheck.md")
end

-- We can use use internal linter.
-- See `CHXFPCCheck.md` before uncomment
--
-- function UseInternalLinter([...])
--
--   linter.removeLinter("fpc")
--
--   linter.makeLinter("fpc", "pascal", "fpc", -- ID, filetype, executable
--
--     {"-Cn",                  -- "-Cn" = Compile ".o" (Don't recompile unchanged)
--                              -- or "-s" = Don't Assemble (but regenate asm?)
--     "@"..CFGFile,            -- Config file, add only if used
--     "-FU"..TmpDir,           -- Temp output dir for .o .ppu
--     "-FE"..TmpDir,           -- Temp output dir for executable
--     "-Fu"..TmpDir,           -- Search precompiled units in output dir
--     "-Fu./*",                -- Search units in working directory subdirs.
--     "-Fu./../*",             -- Search units in working directory brothers.
--     "-Fu"..FileDir.."/*",    -- Search units in souce file directory subdirs.
--     "-Fu"..FileDir.."/../*", -- Search units in souce file directory brothers.
--     "-v0ewnh",               -- "0" = Minimal verbosity; "e" = Error;
--                              -- "w" = Warning; "n" = Note; "h" = Hint
--     "-l-",                   -- Remove Name and copyright, less output lines
--     SourceFilePath},         -- Current source file path
--
--     "%f%(%l,%c%) %m"         -- Output regex
--     -- Actually FPC can generate gcc like output with "-vr"
--
--   )  -- `linter.makeLinter` Can have more parameters. See `help linter`
-- end

local function CheckPascalFile(buf)
  if buf.Settings["filetype"] ~= "pascal" then
    micro.InfoBar():Error("Filetype must be 'pascal'")
    return false;
  end

  if buf:Modified() then
    buf:Save()
  end

  if buf.AbsPath == "" then
    micro.InfoBar():Error("File must be saved before")
    return false
  end

  return true
end

local function SetCFGFile(Caller, bp)
  -- WARNING: Asyncronous method here, stop the other thread.

  local BufName = bp.Buf:GetName()
  if not FPCcfg[BufName] then
    -- This asyncronous Prompt is shit...
    micro.InfoBar():Prompt("FPC config file [Tab]: ", "", "FPCConfig", nil,
      function (resp, canceled)
        if resp == "" then
          FPCcfg[BufName] = ""
        else
          FPCcfg[BufName] = filepath.Abs(resp)
        end

        -- Calling again main function...
        Caller(bp)
      end
    )
  end
end

local function FPCCompile(buf, CFGFile, Args)
  if CFGFile and CFGFile ~= "" then
    -- micro.InfoBar():Message("CFG: " .. CFGFile)
    table.insert(Args, 1, "@" .. CFGFile) -- Actually order is not important.
  end
  table.insert(Args, buf.AbsPath) -- Adding file

  local cmd = "fpc " .. table.concat(Args, " ")
  micro.InfoBar():Message("Exec: " .. cmd)

  -- Execute in a terminal tab/split to test
  -- micro.CurPane():HandleCommand("vsplit")
  -- micro.CurPane():HandleCommand("term " .. cmd)

  shell.JobSpawn("fpc", Args, nil, nil, FPCParseExit, buf)
end

function FPCParseExit(output, args)
  -- micro.InfoBar():Message("Parsing output")

  local buf = args[1]

  -- Spliting lines
  local RawLines = {}
  local regex = ("([^%s]+)"):format("\n")
  for each in output:gmatch(regex) do
      table.insert(RawLines, each)
  end

  -- FPC message format: "<File>(<Line>,<Column>) <MsgType>: <Message>"
  -- "-vr" generates output like gcc: <File>: <Line>: <MsgType>: <Col>: <Msg>
  -- Maybe, linter will supports <MsgType> some day.
  regex = ("(..-)%((%d+),(%d+)%)%s(.+):%s(.+)")

  for _,RawLine in ipairs(RawLines) do
    -- RawLine = Line:match("^%s*(.+)%s*$")
    if string.find(RawLine, regex) then
      local file, line, col, msgty, msg = string.match(RawLine, regex)

      -- Teorically, unit or program files can not share same name under
      -- althought in different directories.
      if filepath.Base(buf.Path) == filepath.Base(file) then
        -- Adding buffer messages

        local MsgType = nil
        local msgLow = string.lower(msgty)
        if string.find(msgLow, "fatal", 1, true) or
          string.find(msgLow, "error", 1, true) then
          MsgType = buffer.MTError
        elseif string.find(msgLow, "warning", 1, true) then
          MsgType = buffer.MTWarning
        elseif string.find(msgLow, "note", 1, true) or
          string.find(msgLow, "hint", 1, true) then
          MsgType = buffer.MTInfo
        else
          MsgType = buffer.MTInfo
        end

        local BufMsg = buffer.NewMessage("CHXFPCCheck", msgty..": "..msg,
          buffer.Loc(tonumber(col-1), tonumber(line-1)),
          buffer.Loc(tonumber(col), tonumber(line-1)),
          MsgType)

        buf:AddMessage(BufMsg)
      else
        -- Error message from  another file.
        -- TODO: Add first error from different files to ask later to open it.
      end
    else
      -- Messages not parsed.
    end
  end
end

function CHXFPCCheck(bp)
  bp.Buf:ClearMessages("CHXFPCCheck")

  if not CheckPascalFile(bp.Buf) then
    return false
  end

  SetCFGFile(CHXFPCCheck, bp)
  if not FPCcfg[bp.Buf:GetName()] then return true end
  FPCConfig = FPCcfg[bp.Buf:GetName()]

  -- Getting File directory
  local PasDir = filepath.Abs(bp.Buf.AbsPath)

  os.execute("mkdir -p " .. fpcCacheDir)

  FPCCompile(bp.Buf, FPCConfig,
    {"-Cn",             -- "-Cn" = Compile ".o" (Don't recompile unchanged);
                        -- "-s" = Assemble (Don't compile, but regenate asm?)
    "-FU"..fpcCacheDir, -- Temp output dir for .o .ppu
    "-FE"..fpcCacheDir, -- Temp output dir for executable
    "-Fu"..fpcCacheDir, -- Search precompiled units in output dir
    "-Fu"..PasDir,      -- Search units in pascal file dir
    "-Fu"..PasDir.."/*",-- Search units in pascal file subdirs
    "-Fu./*",           -- Search units working directory subdirs
    "-v0bewnh",          -- "b" = Full paths (needed); "0" = Minimal verbosity
                        -- "e" = Error; "w" = Warning; "n" = Note; "h" = Hint
    "-l-"}              -- Remove version and (C) info
  )
  return true
end
