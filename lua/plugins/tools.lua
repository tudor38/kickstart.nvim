return {
  { -- Prompt local LLMs through Ollama
    'David-Kunz/gen.nvim',
    config = function()
      require('gen').model = 'gemma3n'
    end,
  },

  'mattn/emmet-vim', -- HTML/CSS abbreviation expansion

  { -- Open kitty's scrollback in Neovim
    'mikesmithgh/kitty-scrollback.nvim',
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    version = '^4.0.0', -- pin major version
    opts = {
      search = {
        callbacks = {
          after_ready = function()
            vim.api.nvim_feedkeys('?', 'n', false)
          end,
        },
      },
    },
  },
}
