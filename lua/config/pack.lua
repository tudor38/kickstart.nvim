-- Plugin management with Neovim's built-in vim.pack (`:help vim.pack`).
-- Plugins live in stdpath('data')/site/pack/core/opt; versions are pinned in nvim-pack-lock.json.
--
--   :PackUpdate [names]   fetch updates and review them (`:write` to apply, `:quit` to discard)
--   :PackClean            delete plugins on disk that are no longer added anywhere in the config

local M = {}

-- Topic modules (lua/plugins/<name>.lua), in load order. `deferred` ones load right after startup.
-- A topic that needs things beyond its plugins (parsers, mason packages) returns
--   { ensure = fun(timeout_ms: integer): string[] }
-- which installs them, waits, and lists what is still missing ('parser go'); scripts/sync.lua calls it.
M.modules = {
  startup = {
    'colorscheme', -- first, so everything else draws with it
    'editor',
    'git',
    'lsp',
    'completion', -- before servers start: blink.cmp registers LSP capabilities
    'format',
    'treesitter',
    'markdown', -- these react to the first buffer's FileType
    'quarto',
    'tools',
  },
  deferred = { 'telescope', 'debug' }, -- nothing needed until a key is pressed
}

function M.load(names)
  for _, name in ipairs(names) do
    require('plugins.' .. name)
  end
end

-- Everything still missing for the loaded plugins and every topic's `ensure`, as labels
---@param timeout integer ms
---@param log fun(msg: string)
---@return string[] missing
function M.ensure(timeout, log)
  local missing = {} ---@type string[]
  local function check(label, ensure)
    local m = ensure(timeout)
    log(('%s: %s'):format(label, #m == 0 and 'ok' or (#m .. ' missing')))
    vim.list_extend(missing, m)
  end
  check('plugins', function()
    return vim
      .iter(vim.pack.get())
      :filter(function(p)
        return not vim.uv.fs_stat(p.path)
      end)
      :map(function(p)
        return 'plugin ' .. p.spec.name
      end)
      :totable()
  end)
  for _, name in ipairs(vim.list_extend(vim.list_slice(M.modules.startup), M.modules.deferred)) do
    local topic = require('plugins.' .. name)
    if type(topic) == 'table' and topic.ensure then
      check(name, topic.ensure)
    end
  end
  return missing
end

function M.gh(repo)
  return 'https://github.com/' .. repo
end

-- Build steps that lazy.nvim used to run (`build = ...`). Registered before any vim.pack.add()
-- so they also run on first install. They live here, keyed by name, rather than in each topic's
-- spec `data`: on a fresh machine the first vim.pack.add() installs every plugin in the lockfile,
-- before the topics that would carry that `data` have run.
local function run(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local output = (result.stderr ~= '' and result.stderr) or result.stdout or ''
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

local builds = {
  ['telescope-fzf-native.nvim'] = function(path)
    run('telescope-fzf-native.nvim', { 'make' }, path)
  end,
  LuaSnip = function(path)
    run('LuaSnip', { 'make', 'install_jsregexp' }, path) -- regex support in snippets
  end,
  ['nvim-treesitter'] = function(_, active)
    if not active then
      vim.cmd.packadd 'nvim-treesitter'
    end
    vim.cmd 'TSUpdate'
  end,
}

vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack-build', { clear = true }),
  callback = function(ev)
    local build = builds[ev.data.spec.name]
    if build and (ev.data.kind == 'install' or ev.data.kind == 'update') then
      build(ev.data.path, ev.data.active)
    end
  end,
})

vim.api.nvim_create_user_command('PackUpdate', function(opts)
  vim.pack.update(#opts.fargs > 0 and opts.fargs or nil)
end, { nargs = '*', desc = 'Update plugins (all, or the named ones)' })

vim.api.nvim_create_user_command('PackClean', function()
  -- Deferred modules may not have added their plugins yet; they'd look unused
  M.load(M.modules.deferred)
  local unused = vim
    .iter(vim.pack.get())
    :filter(function(p)
      return not p.active
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()
  if #unused == 0 then
    vim.notify 'No unused plugins'
    return
  end
  vim.pack.del(unused)
  vim.notify('Deleted: ' .. table.concat(unused, ', '))
end, { desc = 'Delete plugins no longer in the config' })

return M
