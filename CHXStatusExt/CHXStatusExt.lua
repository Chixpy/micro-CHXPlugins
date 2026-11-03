VERSION = "1.0.0"

local micro = import("micro")
local Config = import("micro/config")
local Buffer = import("micro/buffer")
local Util = import("micro/util")
local FilePath = import("filepath")
local GoOS = import("os")
local time = import("time")

local GitRootCache = {} -- Root path of git files
local ModifCache = {} -- Last save time

function init()
  -- Functions to write info in current buffer as an extra
  Config.TryBindKey("Alt-D", "lua:CHXStatusExt.CHXInsertDate", false)
  Config.MakeCommand("CHXInsertDate", CHXInsertDate, Config.NoComplete)
  Config.TryBindKey("Alt-H", "lua:CHXStatusExt.CHXInsertTime", false)
  Config.MakeCommand("CHXInsertTime", CHXInsertTime, Config.NoComplete)
  Config.TryBindKey("Alt-F", "lua:CHXStatusExt.CHXInsertPath", false)
  Config.MakeCommand("CHXInsertPath", CHXInsertPath, Config.NoComplete)

  micro.SetStatusInfoFn("CHXStatusExt.AbsPath")
  --< Absolute full file path

  micro.SetStatusInfoFn("CHXStatusExt.AbsDir")
  --< Absolute full file directory

  micro.SetStatusInfoFn("CHXStatusExt.GitRelDir")
  --< Relative file from file's git base directory
  --<   - if not a repository file then same as WorkRelDir()

  micro.SetStatusInfoFn("CHXStatusExt.microRelDir")
  --< File directory as it's opened in micro

  micro.SetStatusInfoFn("CHXStatusExt.WorkRelDir")
  --< Relative file directory (from current working directory, always)

  micro.SetStatusInfoFn("CHXStatusExt.Time")
  --< Current time (updated only in events)

  micro.SetStatusInfoFn("CHXStatusExt.Date")
  --< Current date (updated only in events)

  micro.SetStatusInfoFn("CHXStatusExt.FileModifTime")
  --< First modification time (≈ time of last saved modification)

  micro.SetStatusInfoFn("CHXStatusExt.FileElapTime")
  --< Time elapsed from last save

  Config.AddRuntimeFile("CHXStatusExt", Config.RTHelp, "CHXStatusExt.md")
end

function onBufferClose(buf)
  -- Liberando cache de directorio base de git
  if GitRootCache[buf.AbsPath] ~= nil then
    GitRootCache[buf.AbsPath] = nil
  end
end

function AbsPath(buf)
  return buf.AbsPath
end

function AbsDir(buf)
  return FilePath.Dir(buf.AbsPath)
end

local function FindGitRoot(dir)
  while dir ~= "" and dir ~= FilePath.Separator do
    local GitDir = FilePath.Join(dir, ".git")
    local Info, err = GoOS.Stat(GitDir)
    if err == nil then
      return dir
    end

    local Parent = FilePath.Dir(dir)
    if Parent == dir then
      break
    end
    dir = Parent
  end
  return nil
end

function GitRelDir(buf)
  if buf.Path == nil or buf.Path == "" then
    return "[No file] "
  end

  local key = buf.AbsPath
  local FileDir = FilePath.Dir(buf.AbsPath)
  local RootDir = GitRootCache[key]

  if RootDir == nil then
    RootDir = FindGitRoot(FileDir)

    if RootDir == nil then
      local WDir, err = GoOS.Getwd()
      RootDir = (err == nil) and WDir or FileDir
    end

    GitRootCache[key] = RootDir
  end

  local GitDir = FilePath.Base(RootDir)
  local RelPath, relerr = FilePath.Rel(RootDir, FileDir)
  if relerr ~= nil then
    return FileDir
  end

  if RelPath == "" then
    RelPath = "."
  end

  return "[" .. GitDir .. "] " .. RelPath
end

function microRelDir(buf)
  return FilePath.Dir(buf.Path)
end

function WorkRelDir(buf)
  if buf.Path == nil or buf.Path == "" then
    return ""
  end

  local FileDir = AbsDir(buf)

  local WDir, err = GoOS.Getwd()
  if err ~= nil then
    return FileDir
  end

  local RelPath, relerr = FilePath.Rel(WDir, FileDir)
  if relerr ~= nil then
    return FileDir
  end

  return RelPath
end

function Time(buf)
  return time.Now():Format("15:04:05")
end

function Date(buf)
  return time.Now():Format("2006/01/02")
end

local function CacheModTime(buf)
  local key = buf:GetName()

  -- Not modified
  if not buf:Modified() then
    if ModifCache[key] then
      ModifCache[key] = nil
    end

    return nil
  end

  -- Not in cache
  if ModifCache[key] == nil then
    ModifCache[key] = time.Now()
  end

  return ModifCache[key]
end

function FileModifTime(buf)
  local ModTime = CacheModTime(buf)

  if ModTime == nil then
    return ""
  end

  return ModTime:Format("15:04:05")
end

function FileElapTime(buf)
  local ModTime = CacheModTime(buf)

  if ModTime == nil then
    return ""
  end

  local currentSec = time.Now():Unix()
  local modSec = ModTime:Unix()

  local totalSeconds = currentSec - modSec
  if totalSeconds < 0 then totalSeconds = 0 end

  local minutes = math.floor(totalSeconds / 60)
  local seconds = totalSeconds % 60

  return string.format("%02d:%02d", minutes, seconds)
end

function CHXInsertDate(bp)
  local count = bp.Buf:NumCursors()

  for i = 0, count - 1 do
    local aCursor = bp.Buf:GetCursor(i)
    if aCursor then
      if aCursor:HasSelection() then
          aCursor:DeleteSelection()
          aCursor:ResetSelection()
      end

    bp.Buf:Insert(Buffer.Loc(aCursor.X, aCursor.Y),
      time.Now():Format("2006/01/02"))
    end
  end

  return true
end

function CHXInsertTime(bp)
  local count = bp.Buf:NumCursors()

  for i = 0, count - 1 do
    local aCursor = bp.Buf:GetCursor(i)
    if aCursor then
      if aCursor:HasSelection() then
          aCursor:DeleteSelection()
          aCursor:ResetSelection()
      end

    bp.Buf:Insert(Buffer.Loc(aCursor.X, aCursor.Y),
      time.Now():Format("15:04:05"))
    end
  end

  return true
end

function CHXInsertPath(bp)
  local count = bp.Buf:NumCursors()

  for i = 0, count - 1 do
    local aCursor = bp.Buf:GetCursor(i)
    if aCursor then
      if aCursor:HasSelection() then
          aCursor:DeleteSelection()
          aCursor:ResetSelection()
      end

      bp.Buf:Insert(Buffer.Loc(aCursor.X, aCursor.Y), bp.Buf.AbsPath)
    end
  end

  return true
end
