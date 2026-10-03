# Neovim config

My personal Neovim configuration. It started as a fork of
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) and has since diverged: it is split into
modules, manages plugins with Neovim's built-in [`vim.pack`](https://neovim.io/doc/user/pack.html#vim.pack),
uses blink.cmp for completion, and targets **Neovim 0.12**.

## Requirements

- Neovim 0.12
- [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) 0.26.1+ (nvim-treesitter `main` builds parsers with it)
- `git`, `make`, a C compiler (treesitter parsers, telescope-fzf-native, LuaSnip regex support)
- [ripgrep](https://github.com/BurntSushi/ripgrep) for Telescope grep pickers
- A [Nerd Font](https://www.nerdfonts.com/) (`vim.g.have_nerd_font` in `init.lua`)
- Language toolchains for the servers you use: Node (ts_ls, prettier), Python (basedpyright, ruff), Go (gopls, gofmt)
- Optional: [lazygit](https://github.com/jesseduffield/lazygit), [Ollama](https://ollama.com/) (gen.nvim),
  [Quarto](https://quarto.org/), and `latex2text` for math in Markdown (`uv tool install pylatexenc`)

## Install

```sh
git clone git@github.com:tudor38/kickstart.nvim.git ~/.config/nvim
nvim  # vim.pack asks to install plugins (at the revisions in nvim-pack-lock.json); mason installs servers and formatters
```

## Layout

```
init.lua                 leader keys, then requires the config modules
lua/config/
  options.lua            editor options
  keymaps.lua            general keymaps (plugin keymaps live with their plugin)
  autocmds.lua           yank highlight, <leader>x run-file
  pack.lua               vim.pack build hooks, :PackUpdate / :PackClean
lua/plugins/
  colorscheme.lua        onedark
  completion.lua         blink.cmp + LuaSnip
  debug.lua              nvim-dap + dap-ui (Go, Python)
  editor.lua             which-key, mini.nvim, leap, outline, todo-comments, vim-sleuth
  format.lua             conform.nvim (format on save)
  git.lua                gitsigns, lazygit
  lsp.lua                language servers via mason + lspconfig, diagnostics
  markdown.lua           render-markdown (incl. LaTeX as Unicode)
  quarto.lua             quarto-nvim + otter, img-clip, nabla
  telescope.lua          fuzzy finder pickers
  tools.lua              gen.nvim, emmet (web filetypes, <C-z> prefix)
  treesitter.lua         parsers, highlighting, indent
```

`lua/config/pack.lua` lists the plugin modules in load order; telescope and debug load right after startup.

## Plugins

Each module in `lua/plugins/` calls `vim.pack.add()` and then configures its plugins. To add one, add it to
the matching module (or a new module listed in `init.lua`). Plugins are installed to
`~/.local/share/nvim/site/pack/core/opt/`, and their exact revisions are pinned in `nvim-pack-lock.json`
(committed).

| Command                 | What                                                                  |
| ----------------------- | --------------------------------------------------------------------- |
| `:PackUpdate [names]`   | Fetch updates and show them; `:write` applies, `:quit` discards       |
| `:PackClean`            | Delete plugins that were removed from the config                      |
| `:checkhealth vim.pack` | Plugin manager status                                                 |

Build steps (telescope-fzf-native, LuaSnip regex, `:TSUpdate`) run on install/update
from `lua/config/pack.lua`. To roll back an update: `git checkout HEAD -- nvim-pack-lock.json`, `:restart`,
then `:lua vim.pack.update(nil, { offline = true, target = 'lockfile' })`.

## Languages

| Language        | LSP                  | Formatter (on save)      |
| --------------- | -------------------- | ------------------------ |
| Lua             | lua_ls (+ lazydev)   | stylua                   |
| Python          | basedpyright, ruff   | ruff                     |
| Go              | gopls                | goimports, gofmt         |
| JS / TS         | ts_ls                | prettier                 |
| CSS, HTML, JSON, YAML | —              | prettier                 |
| Markdown        | marksman             | —                        |

Servers and tools are listed in `lua/plugins/lsp.lua` and installed by mason. Formatters per filetype are in
`lua/plugins/format.lua`. C/C++ is excluded from format on save.

## Keymaps

Leader is `<Space>`. Press it and wait to see which-key's menu; `<leader>sk` searches all keymaps.

| Prefix / key        | What                                                                 |
| ------------------- | -------------------------------------------------------------------- |
| `<leader>s…`        | Search (Telescope): `sf` files, `sg` grep, `sh` help, `sr` resume, … |
| `<leader><leader>`  | Open buffers                                                         |
| `<leader>/`         | Fuzzy find in current buffer                                         |
| `gd`, `gr…`         | LSP: `grr` refs, `gri` impl, `grt` type, `grd`/`grD` def/decl, `grn` rename, `gra` action |
| `gO`, `gW`          | LSP document / workspace symbols                                     |
| `<leader>ca`        | Code action                                                          |
| `<leader>f`         | Format buffer                                                        |
| `<leader>q`         | Diagnostics to location list                                         |
| `<leader>h…`        | Git hunks: `hs` stage, `hr` reset, `hp` preview, `hb` blame, `hd` diff |
| `]c` / `[c`         | Next / previous git hunk                                             |
| `<leader>lg`        | LazyGit                                                              |
| `<leader>d…`        | Debug: `dh` breakpoint, `dc` terminate, `dn` run to cursor; `<M-h/j/k/l>` continue/over/out/into, `<F7>` UI |
| `<leader>t…`        | Toggles: `th` inlay hints, `tb` line blame, `tm` math preview        |
| `<leader>i…`        | Insert: `it` timestamp, `ii` image from clipboard                    |
| `<leader>y…`        | Yank: `yp` file path                                                 |
| `<leader>g`         | gen.nvim LLM prompt                                                  |
| `<leader>n`         | File navigator (mini.files)                                          |
| `<leader>a`         | Symbol outline                                                       |
| `<leader>j` / `J`   | Leap (this window / other windows)                                   |
| `<leader>w`         | Write file                                                           |
| `<leader>o`         | Only this window                                                     |
| `<leader>x`         | Run current file (Python, JavaScript)                                |
| `<leader>vv`        | Edit config                                                          |
| `<C-h/j/k/l>`       | Move between windows                                                 |
| `jk`                | Escape (insert mode)                                                 |
| `<Tab>` / `<C-y>`  | Accept completion (Tab also jumps snippet placeholders / indents)    |
| `<F3>`              | Show last search's matches in a new window                           |

Text editing comes from mini.nvim: `sa`/`sd`/`sr` surround, extended `a`/`i` textobjects (`aa`/`ii` for
"next"; `an`/`in` stay Neovim's treesitter incremental selection), autopairs.
Comments use Neovim's built-in `gc`/`gcc`.
