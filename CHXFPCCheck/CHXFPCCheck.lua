VERSION = "1.1.0"

local filepath = import("filepath")
local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local buffer = import("micro/buffer")

local fpcCacheDir = ""
local FPCcfg = {}

local DebugLog = true

function init()
  for _, EnvVar in ipairs({"TMPDIR", "TMP", "HOME"})  do
    local EnvVal = os.getenv(EnvVar)
    if EnvVal ~= "" then
      fpcCacheDir = EnvVal
      break
    end
  end
  fpcCacheDir = fpcCacheDir .. "/micro-CHXFPCCheck"

  config.MakeCommand("CHXFPCCheck", CHXFPCCheck, config.NoComplete)
  config.TryBindKey("Alt-P", "lua:CHXFPCCheck.CHXFPCCheck", false)
  config.AddRuntimeFile("CHXFPCCheck", config.RTHelp, "CHXFPCCheck.md")
end

--  We can use use internal linter.
--  Read `CHXFPCCheck.md` before uncomment.
--
--  function UseInternalLinter(PasFile, TmpDir, CFGFile)
--
--    linter.removeLinter("fpc")
--
--    FileDir = filepath.Dir(PasFile)
--    local Args = {
--      "-s",                    -- "-s" = Don't Assemble or "-Cn" = Compile ".o"
--      "-FU"..TmpDir,           -- Temp output dir for .o .ppu
--      "-FE"..TmpDir,           -- Temp output dir for executable
--      "-Fu"..TmpDir,           -- Search precompiled units in output dir
--      "-Fu./*",                -- Search units in working directory subdirs.
--      "-Fu../*",               -- Search units in working directory brothers.
--      "-Fu"..FileDir.."/*",    -- Search units in souce file directory subdirs.
--      "-Fu"..FileDir.."/../*", -- Search units in souce file directory brothers.
--      "-v0ewnh",               -- "0" = Minimal verbosity; "e" = Error;
--                               -- "w" = Warning; "n" = Note; "h" = Hint
--      "-l-",                   -- Remove Name and copyright, less output lines
--      PasFile                  -- Current source file path
--    }
--
--    if CFGFile ~= "" then
--      table.insert(Args, 1, "@"..CFGFile) -- Config file, add only if used
--    end
--
--    -- `linter.makeLinter` Can have more parameters. See `help linter`
--    linter.makeLinter("fpc", "pascal", "fpc", -- ID, filetype, executable
--      Args, "%f%(%l,%c%) %m")                 -- Args, output line regex
--  end

local function WriteLog(Text)
  if DebugLog then
    micro.Log(Text)
  end
end

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
    return false
  end
  return true
end

local function findPaneInTabs(targetFile)
-- Returns the first tab index and pane with a targetFile buffer
-- targetFile must be and absolute path.
  local tabs = micro.Tabs()
  if tabs ~= nil and tabs.List ~= nil then
    for i = 1, #tabs.List do
      local tab = tabs.List[i]
      if tab.Panes ~= nil then
        for j = 1, #tab.Panes do
          local pane = tab.Panes[j]
          if pane and pane.Buf
          and pane.Buf.AbsPath == targetFile
          then
            return i, pane -- Return Tab Index and Pane
          end
        end
      end
    end
  end
  return nil, nil
end

local function FPCCompile(buf, CFGFile, Args)
  if CFGFile and CFGFile ~= "" then
    -- micro.InfoBar():Message("CFG: " .. CFGFile)
    table.insert(Args, 1, "@" .. CFGFile) -- Actually order is not important.
  end
  table.insert(Args, buf.AbsPath) -- Adding file

  local cmd = "fpc " .. table.concat(Args, " ")
  micro.InfoBar():Message("Wait: " .. cmd)
  WriteLog(cmd)

  -- Execute in a terminal tab/split to test
  -- micro.CurPane():HandleCommand("vsplit")
  -- micro.CurPane():HandleCommand("term " .. cmd)

  shell.JobSpawn("fpc", Args, nil, nil, FPCParseExit)
end

function FPCParseExit(output)
  -- Spliting lines
  local RawLines = {}
  for each in output:gmatch("([^\n]+)") do
      table.insert(RawLines, each)
  end
  -- FPC message format: "<File>(<Line>,<Column>) <MsgType>: <Message>"
  -- "-vr" generates output like gcc: <File>: <Line>: <MsgType>: <Col>: <Msg>
  -- Maybe, linter will support <MsgType> some day.
  local regex = "(.-)%((%d+),(%d+)%)%s*(.-):%s*(.+)"

  -- Parse messages and group by file (Sometimes fcp references previous files)
  local messagesByFile = {}
  local firstError = nil
  for _, RawLine in ipairs(RawLines) do
    if string.find(RawLine, regex) then
      local file, line, col, msgty, msg = string.match(RawLine, regex)
      local absFile = filepath.Abs(file)

      if not messagesByFile[absFile] then
        messagesByFile[absFile] = { hasError = false, items = {} }
      end

      local msgLow = string.lower(msgty)
      local MsgType = buffer.MTInfo

      if string.find(msgLow, "fatal", 1, true)
      or string.find(msgLow, "error", 1, true) then
        MsgType = buffer.MTError
        messagesByFile[absFile].hasError = true

        if not firstError then
          firstError = {
            file = absFile,
            line = tonumber(line) - 1,
            col = tonumber(col) - 1,
            msg = msgty..": "..msg
          }
        end

      elseif string.find(msgLow, "warning", 1, true) then
        MsgType = buffer.MTWarning

      -- else if string.find(msgLow, "fatal", 1, true)
      -- or string.find(msgLow, "error", 1, true) then
      --   MsgType = buffer.MTInfo
      end

      local BufMsg = buffer.NewMessage("CHXFPCCheck", msgty..": "..msg,
        buffer.Loc(tonumber(col) - 1, tonumber(line) - 1),
        buffer.Loc(tonumber(col), tonumber(line) - 1),
        MsgType)

      table.insert(messagesByFile[absFile].items, BufMsg)
    else
      -- not string.find(RawLine, regex) -> Other messages
      WriteLog("Other Msg: "..RawLine)
    end;
  end

  -- Adding messagges to buffers
  for targetFile, data in pairs(messagesByFile) do
    local targetBuf = nil

    -- Searching if file is already opened
    local TabIdx, targetPane = findPaneInTabs(targetFile)
    if targetPane then
      targetBuf = targetPane.Buf
    end

    -- if file is not opened and it has an Error/Fatal open it in a new tab
    if not targetBuf and data.hasError then
      micro.CurPane():NewTabCmd({targetFile})

      -- Researching new pane and buf...
      TabIdx, targetPane = findPaneInTabs(targetFile)
      if targetPane then
        targetBuf = targetPane.Buf
      end
    end

    -- If found then add all messages for it
    if targetBuf then
      targetBuf:ClearMessages("CHXFPCCheck")
      for _, msgObj in ipairs(data.items) do
        targetBuf:AddMessage(msgObj)
      end
    end
  end

  -- Move cursor to first Error/Fatal found
  if firstError then
    local TabIdx, targetPane = findPaneInTabs(firstError.file)

    if targetPane then
      micro.Tabs():SetActive(TabIdx - 1)
      targetPane:SetActive(true)
    else
      targetPane = micro.CurPane()
    end

    targetPane.Cursor.X = firstError.col
    targetPane.Cursor.Y = firstError.line
    targetPane:Relocate()

    micro.InfoBar():Message(filepath.Base(firstError.file) .. ": " .. firstError.msg)
  else
    micro.CurPane().Buf:ClearMessages("CHXFPCCheck")
    micro.InfoBar():Message("CHXFPCCheck: Done.")
  end
end

function CHXFPCCheck(bp)
  if not CheckPascalFile(bp.Buf) then
    return false
  end

  SetCFGFile(CHXFPCCheck, bp)
  if not FPCcfg[bp.Buf:GetName()] then return true end -- Stop asyncronious
  FPCConfig = FPCcfg[bp.Buf:GetName()]

  bp.Buf:ClearMessages("CHXFPCCheck")

  -- Getting File directory
  local PasDir = filepath.Abs(bp.Buf.AbsPath)

  os.execute("mkdir -p " .. fpcCacheDir)

  FPCCompile(bp.Buf, FPCConfig,
    {"-s",                  -- "-s" = Assemble or "-Cn" = Compile ".o"
    "-FU"..fpcCacheDir,     -- Temp output dir for .o .ppu
    "-FE"..fpcCacheDir,     -- Temp output dir for executable (can override FU)
    "-Fu"..fpcCacheDir,     -- Search precompiled units in output dir
    -- "-Fu"..PasDir,          -- Search units in pascal file dir added by default
    "-Fu"..PasDir.."/*",    -- Search units in pascal file subdirs
    "-Fu"..PasDir.."/../*", -- Search units in pascal file brothers
    --"-Fu.",               -- Working directory is added by default
    "-Fu./*",           -- Search units working directory subdirs
    "-Fu../*",          -- Search units working directory brothers
    "-v0bewnh",         -- "b" = Full paths (REQUIRED); "0" = Minimal verbosity
                        -- "e" = Error; "w" = Warning; "n" = Note; "h" = Hint
    "-l-"}              -- Remove version and (C) info
  )
  return true
end
