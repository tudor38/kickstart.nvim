-- Installs everything the config needs, headlessly, then exits non-zero if anything is missing.
-- Run by install.sh; also usable on its own: nvim --headless -l scripts/sync.lua
--
--   plugins      vim.pack, at the revisions in nvim-pack-lock.json (build hooks in config/pack.lua run on install)
--   parsers      nvim-treesitter, the list in plugins/treesitter.lua
--   mason        servers and tools from plugins/lsp.lua, debug adapters from plugins/debug.lua

local TIMEOUT = 20 * 60 * 1000
local failed = {} ---@type string[]

local function log(msg)
  print(msg)
end

-- `-l` skips the user config, so load it here, plus the modules init.lua defers to VimEnter
vim.cmd.source(vim.fn.stdpath 'config' .. '/init.lua')
local pack = require 'config.pack'
pack.load(pack.modules.deferred)

log 'plugins:'
for _, p in ipairs(vim.pack.get()) do
  if not vim.uv.fs_stat(p.path) then
    table.insert(failed, 'plugin ' .. p.spec.name)
  end
end
log(('  %d installed'):format(#vim.pack.get()))

log 'treesitter parsers:'
local parsers = require('plugins.treesitter').parsers
-- Joins any install already started by plugins/treesitter.lua
require('nvim-treesitter').install(parsers):wait(TIMEOUT)
local installed = require('nvim-treesitter').get_installed 'parsers'
for _, lang in ipairs(parsers) do
  if not vim.list_contains(installed, lang) then
    table.insert(failed, 'parser ' .. lang)
  end
end
log(('  %d/%d installed'):format(#vim.tbl_filter(function(lang)
  return vim.list_contains(installed, lang)
end, parsers), #parsers))

log 'mason packages:'
vim.cmd 'MasonToolsInstallSync'

local registry = require 'mason-registry'
local to_package = require('mason-nvim-dap.mappings.source').nvim_dap_to_package
local adapters = vim.tbl_map(function(adapter)
  return to_package[adapter] or adapter
end, require('mason-nvim-dap.settings').current.ensure_installed)
for _, name in ipairs(adapters) do
  local pkg = registry.get_package(name)
  if not pkg:is_installed() and not pkg:is_installing() then
    pkg:install()
  end
end
vim.wait(TIMEOUT, function()
  return vim.iter(registry.get_all_packages()):all(function(pkg)
    return not pkg:is_installing()
  end)
end, 500)

for _, name in ipairs(vim.list_extend(vim.deepcopy(require('plugins.lsp').tools), adapters)) do
  if not registry.is_installed(name) then
    table.insert(failed, 'mason ' .. name)
  end
end
-- Every server that's enabled must be able to start
for _, config in ipairs(vim.lsp.get_configs { enabled = true }) do
  local cmd = config.cmd
  if type(cmd) == 'table' and vim.fn.executable(cmd[1]) == 0 then
    table.insert(failed, ('server %s (%s not found)'):format(config.name, cmd[1]))
  end
end
log(('  %d installed'):format(#registry.get_installed_package_names()))

if #failed > 0 then
  log '\nmissing:'
  for _, f in ipairs(failed) do
    log('  ' .. f)
  end
  os.exit(1)
end
log '\nall set; run :checkhealth in nvim for details'
os.exit(0)
