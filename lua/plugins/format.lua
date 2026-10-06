local gh = require('config.pack').gh

vim.pack.add { gh 'stevearc/conform.nvim' }

-- Formatters mason installs (ruff and gofmt come with their language server and toolchain)
local tools = { 'stylua', 'prettier', 'goimports' }
require('config.mason').install(tools)

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- No standard style for C/C++, so don't format on save there
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_organize_imports', 'ruff_format' },
    go = { 'goimports', 'gofmt' },
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    css = { 'prettier' },
    scss = { 'prettier' },
    html = { 'prettier' },
    json = { 'prettier' },
    yaml = { 'prettier' },
  },
}

vim.keymap.set('', '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })

return {
  ensure = function(timeout)
    return require('config.mason').sync(tools, timeout)
  end,
}
