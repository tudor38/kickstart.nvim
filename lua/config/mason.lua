-- Mason packages that topic modules need (`:help mason.nvim`). Takes mason package names, not
-- lspconfig or nvim-dap names. Needs mason.nvim added and set up first (plugins/lsp.lua does it).
--
--   install(names)        at startup: install whatever is missing in the background
--   sync(names, timeout)  in a topic's `ensure`: install, wait, and return what is still missing

local M = {}

local queued = {} ---@type string[]
local refreshing = false

local function start(name)
  local registry = require 'mason-registry'
  if not registry.has_package(name) then
    vim.notify('mason: no package named ' .. name, vim.log.levels.ERROR)
    return
  end
  local pkg = registry.get_package(name)
  if pkg:is_installed() or pkg:is_installing() then
    return
  end
  pkg:install({}, function(ok, err)
    if not ok then
      vim.schedule(function()
        vim.notify(('mason: installing %s failed:\n%s'):format(name, tostring(err)), vim.log.levels.ERROR)
      end)
    end
  end)
end

---@param names string[]
function M.install(names)
  vim.list_extend(queued, names)
  if refreshing then
    return
  end
  -- One registry refresh for every topic that asks during startup
  refreshing = true
  require('mason-registry').refresh(vim.schedule_wrap(function()
    refreshing = false
    local pending = queued
    queued = {}
    vim.iter(pending):each(start)
  end))
end

---@param names string[]
---@param timeout integer ms
---@return string[] missing labels, e.g. 'mason stylua'
function M.sync(names, timeout)
  local registry = require 'mason-registry'
  registry.refresh() -- blocking without a callback
  vim.iter(names):each(start)
  vim.wait(timeout, function()
    return vim.iter(names):all(function(name)
      return not (registry.has_package(name) and registry.get_package(name):is_installing())
    end)
  end, 500)
  return vim
    .iter(names)
    :filter(function(name)
      return not registry.is_installed(name)
    end)
    :map(function(name)
      return 'mason ' .. name
    end)
    :totable()
end

return M
