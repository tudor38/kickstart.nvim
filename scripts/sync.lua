-- Installs everything the config needs, headlessly, then exits non-zero if anything is missing.
-- Run by install.sh; also usable on its own: nvim --headless -l scripts/sync.lua
--
-- Plugins install as the config loads (build hooks in config/pack.lua); each topic module's
-- `ensure` installs the rest (parsers, mason packages) and reports what is still missing.

local TIMEOUT = 20 * 60 * 1000

-- `-l` skips the user config, so load it here, plus the modules init.lua defers to VimEnter
vim.cmd.source(vim.fn.stdpath 'config' .. '/init.lua')
local pack = require 'config.pack'
pack.load(pack.modules.deferred)

local missing = pack.ensure(TIMEOUT, print)
if #missing > 0 then
  print '\nmissing:'
  for _, m in ipairs(missing) do
    print('  ' .. m)
  end
  os.exit(1)
end
print '\nall set; run :checkhealth in nvim for details'
os.exit(0)
