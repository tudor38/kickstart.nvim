return {
  { -- Snippet engine
    'L3MON4D3/LuaSnip',
    version = '2.*',
    build = (function()
      -- Regex support in snippets needs make (not available on Windows by default)
      if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
        return
      end
      return 'make install_jsregexp'
    end)(),
    opts = {},
  },

  { -- Autocompletion. LSP capabilities are registered automatically on Neovim 0.11+.
    'saghen/blink.cmp',
    version = '1.*', -- release tags ship the prebuilt Rust fuzzy matcher
    -- Not lazy-loaded: its LSP capabilities must be registered before servers start (it lazy-loads internally)
    dependencies = { 'L3MON4D3/LuaSnip', 'folke/lazydev.nvim' },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' is close to built-in completion (`:help ins-completion`):
        -- <C-y> accept, <C-Space> open menu/docs, <C-n>/<C-p> select, <C-b>/<C-f> scroll docs,
        -- <C-e> hide, <C-k> toggle signature help, <Tab>/<S-Tab> jump through snippet placeholders
        preset = 'default',
        -- Also jump through snippet placeholders with <C-l>/<C-h>
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        -- Preselect the first item without inserting it (like completeopt=noinsert)
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets' },
        providers = {
          -- Neovim API completions in Lua files; ranked above LuaLS
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
      signature = { enabled = true }, -- signature help while typing arguments
    },
  },
}
