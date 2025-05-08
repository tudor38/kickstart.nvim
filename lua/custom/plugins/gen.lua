-- https://github.com/David-Kunz/gen.nvim
return {
  'David-Kunz/gen.nvim',
  config = function()
    require('gen').model = 'mistral-nemo:latest'
  end,
}
