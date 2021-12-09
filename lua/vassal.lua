--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local fn = vim.fn
local api = vim.api

local jobs = {}
local _commands = {}

local function on_exit(id, code)
  if code == 0 then
    print(string.format('✓ [%s]', jobs[id]))
  else
    api.nvim_err_writeln(
      string.format('✕ [%s] command failed, exit code [%d]', jobs[id], code)
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
    print(string.format('running [%s]', command))
    local job_id = fn.jobstart(command, options)
    if job_id == 0 then
      api.nvim_err_writeln('[vassal] invalid argument')
      return
    elseif job_id == -1 then
      api.nvim_err_writeln('[vassal] command or shell is not executable')
      return
    end
    jobs[job_id] = command
  end
end

local function commands(cmds)
  _commands = cmds or {}
end

vim.cmd([[command Vassal lua require('vassal').launch()]])
vim.cmd([[command Vl lua require('vassal').launch()]])

local M = {
  launch = launch,
  commands = commands,
}

return M
