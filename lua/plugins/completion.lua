local gh = require('config.pack').gh

vim.pack.add {
  { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' }, -- snippet engine; built by config/pack.lua
  -- Release tags ship the prebuilt Rust fuzzy matcher. blink registers its LSP capabilities when it
  -- loads, so it must be added before language servers start (lsp.lua only enables them).
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' },
}

require('luasnip').setup {}

require('blink.cmp').setup {
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
}
