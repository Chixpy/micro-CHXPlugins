-- jumptag - Jump to any function, class or heading with F4. Go, Python, C...
-- Copyright 2020-2021 Tero Karvinen http://TeroKarvinen.com
-- https://github.com/terokarvinen/micro-jump
-- MIT license

local config = import("micro/config")
local shell = import("micro/shell")
local micro = import("micro")

function init()
	config.MakeCommand("jumptag", jumptagCommand, config.NoComplete)
	config.TryBindKey("F4", "command:jumptag", true)
end

function jumptagCommand(bp) -- bp BufPane
		local filename = bp.Buf.Path

		-- CHX added "cut -f1,4-" to show only tag and line number
		local cmd = string.format("bash -c \"ctags -f - --fields=n '%s'| cut -f1,4- |fzf --layout=reverse|tr ':' '\n'|tail -1\"", filename)
		local out = shell.RunInteractiveShell(cmd, false, true)
		if tonumber(out) == nil then
			micro.InfoBar():Message("Jump cancelled.")
			return
		end
		local linenum = tonumber(out)-1
		bp.Cursor.Y = linenum

		-- CHX: Fixed line number not showing in message.
		micro.InfoBar():Message(string.format("Jumped to line %d", linenum))
end
