-- lazydev itself is configured in init.lua; this only removes the legacy neodev if present.
return {
  { 'folke/neodev.nvim', enabled = false },
}
