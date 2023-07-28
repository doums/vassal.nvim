-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at https://mozilla.org/MPL/2.0/.

local fn = vim.fn
local lvl = vim.log.levels

local jobs = {}
local _commands = {}

local function on_exit(id, code)
  if code == 0 then
    vim.notify(string.format('✓ [%s]', jobs[id]), lvl.INFO)
  else
    vim.notify(
      string.format('✕ [%s] command failed, exit code [%d]', jobs[id], code),
      lvl.ERROR
    )
  end
  jobs[id] = nil
end

local options = {
  detach = true,
  on_exit = on_exit,
}

local function launch()
  for _, command in ipairs(_commands) do
    vim.notify(string.format('running [%s]', command), lvl.INFO)
    local job_id = fn.jobstart(command, options)
    if job_id == 0 then
      vim.notify('[vassal] invalid argument', lvl.ERROR)
      return
    elseif job_id == -1 then
      vim.notify('[vassal] command or shell is not executable', lvl.ERROR)
      return
    end
    jobs[job_id] = command
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
