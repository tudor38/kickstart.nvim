local gh = require('config.pack').gh

vim.pack.add {
  gh 'folke/lazydev.nvim',
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  gh 'j-hui/fidget.nvim',
}

-- Lua LSP for Neovim config/runtime/plugin APIs
require('lazydev').setup {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}
require('mason').setup()
require('fidget').setup {} -- LSP status updates

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    -- Telescope loads just after startup, possibly after a server attaches: resolve pickers on use
    local picker = function(name)
      return function()
        require('telescope.builtin')[name]()
      end
    end

    -- Built-in `gr` prefix (`:help lsp-defaults`); grn/gra are Neovim's own defaults.
    -- Lists go through Telescope pickers.
    map('gd', picker 'lsp_definitions', '[G]oto [D]efinition')
    map('grd', picker 'lsp_definitions', '[G]oto [D]efinition')
    map('grr', picker 'lsp_references', '[G]oto [R]eferences')
    map('gri', picker 'lsp_implementations', '[G]oto [I]mplementation')
    map('grt', picker 'lsp_type_definitions', '[G]oto [T]ype definition')
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gO', picker 'lsp_document_symbols', 'Open document symbols')
    map('gW', picker 'lsp_dynamic_workspace_symbols', 'Open workspace symbols')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Highlight references of the word under the cursor while it rests there
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = { source = 'if_many', spacing = 2 },
}

-- Language servers to install and enable. Keys are nvim-lspconfig names (`:help lspconfig-all`);
-- values are merged into that server's default config.
local servers = {
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          -- basedpyright defaults to 'recommended' (flags every Any/Unknown, typing.List, etc.);
          -- 'standard' is plain pyright's default: real type errors only. Projects can override it.
          typeCheckingMode = 'standard',
        },
      },
    },
  },
  ruff = {
    -- Lint/fix only; leave hover to basedpyright
    on_attach = function(client)
      client.server_capabilities.hoverProvider = false
    end,
    init_options = {
      settings = {
        -- Without a project ruff config, lint only for likely bugs (ruff's classic defaults:
        -- pycodestyle errors + pyflakes), not style or modernization. Project configs win.
        configurationPreference = 'filesystemFirst',
        lint = { select = { 'E4', 'E7', 'E9', 'F' } },
      },
    },
  },
  -- Default filetype lists include ones Neovim doesn't define (gotmpl, markdown.mdx),
  -- which :checkhealth flags
  gopls = { filetypes = { 'go', 'gomod', 'gowork' } },
  ts_ls = {},
  marksman = { filetypes = { 'markdown' } },
  lua_ls = {
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
      },
    },
  },
}

-- Non-LSP tools for mason to install (formatters, etc.)
local tools = { 'stylua', 'prettier', 'goimports' }

require('mason-tool-installer').setup { ensure_installed = vim.list_extend(vim.tbl_keys(servers), tools) }

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
end
-- Enable only the servers above (otherwise mason-lspconfig enables every installed
-- mason package that has an LSP mode, e.g. stylua)
require('mason-lspconfig').setup {
  ensure_installed = {},
  automatic_enable = vim.tbl_keys(servers),
}
