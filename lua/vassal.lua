-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at https://mozilla.org/MPL/2.0/.

local lvl = vim.log.levels
local _commands = {}

local function on_exit(c)
  if c.code == 0 then
    print(c.stdout)
    print(' ✓')
  else
    print(c.stderr)
    print(string.format(' ✕ command failed, exit code [%d]', c.code))
  end
end

local function launch()
  for _, command in ipairs(_commands) do
    if type(command) == 'string' then
      command = vim.split(command, '%s', { trimempty = true })
    end
    local cmd_str = table.concat(command, ' ')
    local s = pcall(vim.system, command, { text = true }, on_exit)
    if s then
      vim.notify(string.format(' … running [%s]', cmd_str), lvl.INFO)
    else
      vim.notify(string.format(' ✕ invalid command [%s]', cmd_str), lvl.ERROR)
    end
  end
end

local function commands(cmds)
  _commands = cmds or {}
end

vim.api.nvim_create_user_command('Vassal', launch, {})
vim.api.nvim_create_user_command('Vl', launch, {})

local M = {
  launch = launch,
  commands = commands,
}

return M
