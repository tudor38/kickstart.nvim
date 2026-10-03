-- Plugin management with Neovim's built-in vim.pack (`:help vim.pack`).
-- Plugins live in stdpath('data')/site/pack/core/opt; versions are pinned in nvim-pack-lock.json.
--
--   :PackUpdate [names]   fetch updates and review them (`:write` to apply, `:quit` to discard)
--   :PackClean            delete plugins on disk that are no longer added anywhere in the config

local M = {}

-- Plugin modules (lua/plugins/<name>.lua), in load order. `deferred` ones load right after startup.
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

function M.gh(repo)
  return 'https://github.com/' .. repo
end

-- Build steps that lazy.nvim used to run (`build = ...`). Registered before any vim.pack.add()
-- so they also run on first install.
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
