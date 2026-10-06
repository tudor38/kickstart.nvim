local gh = require('config.pack').gh

-- nvim-treesitter `main` branch (Neovim 0.12+): installs parsers and queries only.
-- Highlighting and indent are started per buffer below; folding uses vim.treesitter.foldexpr (config/options.lua).
-- Requires tree-sitter-cli >= 0.26.1, curl, tar and a C compiler.
local parsers = {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
  'python', 'go', 'gomod', 'gosum', 'javascript', 'typescript', 'tsx', 'css', 'json', 'yaml', 'toml',
  'latex', -- math in markdown (render-markdown)
}

local function attach(buf, language)
  -- The buffer may be gone by the time an async install finishes
  if not vim.api.nvim_buf_is_valid(buf) or not vim.treesitter.language.add(language) then
    return
  end
  vim.treesitter.start(buf, language)
  if vim.treesitter.query.get(language, 'indents') then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

-- Highlight, edit, and navigate code. :TSUpdate runs after install/update (config/pack.lua).
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

local ts = require 'nvim-treesitter'
ts.install(parsers)

local available = ts.get_available()
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language then
      return
    end
    if vim.tbl_contains(ts.get_installed 'parsers', language) then
      attach(args.buf, language)
    elseif vim.tbl_contains(available, language) then
      -- Auto-install parsers for new languages, then attach
      ts.install(language):await(function()
        attach(args.buf, language)
      end)
    else
      -- Parser may come from Neovim itself or another plugin
      attach(args.buf, language)
    end
  end,
})

-- Code coloring in a buffer comes from treesitter, LSP semantic tokens, and the legacy regex syntax (all three paint)
local function colors_enabled(buf)
  return vim.treesitter.highlighter.active[buf] ~= nil or vim.bo[buf].syntax ~= 'off'
end

local function set_colors(buf, enable)
  if enable == colors_enabled(buf) then
    return
  end
  if enable then
    vim.treesitter.start(buf)
    vim.lsp.semantic_tokens.enable(true, { bufnr = buf })
    -- An empty value means regex syntax was never running; setting it would start it
    local before = vim.b[buf].syntax_before_toggle
    if before and before ~= '' then
      vim.bo[buf].syntax = before
    end
  else
    -- Save first: stopping treesitter re-enables regex syntax via the FileType autocmd
    vim.b[buf].syntax_before_toggle = vim.bo[buf].syntax
    vim.treesitter.stop(buf)
    vim.lsp.semantic_tokens.enable(false, { bufnr = buf })
    vim.bo[buf].syntax = 'off'
  end
end

vim.keymap.set('n', '<leader>tc', function()
  local buf = vim.api.nvim_get_current_buf()
  set_colors(buf, not colors_enabled(buf))
end, { desc = '[T]oggle syntax [C]olors' })

-- Colors (this buffer) plus diagnostics (all buffers, see <leader>td). If either is on, both go off
vim.keymap.set('n', '<leader>tp', function()
  local buf = vim.api.nvim_get_current_buf()
  local enable = not (colors_enabled(buf) or vim.diagnostic.is_enabled())
  set_colors(buf, enable)
  vim.diagnostic.enable(enable)
end, { desc = '[T]oggle [P]lain view (colors + diagnostics)' })

return { parsers = parsers } -- for scripts/sync.lua
