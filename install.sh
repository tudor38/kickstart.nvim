#!/usr/bin/env bash
# Sets up this Neovim config on a Linux machine: dependencies, the config itself, plugins, parsers, mason tools.
# Safe to re-run (skips what's already there; on an existing checkout it pulls and syncs).
#
#   curl -fsSL https://raw.githubusercontent.com/tudor38/kickstart.nvim/master/install.sh | bash
#   ./install.sh [--with-ollama] [--with-quarto] [--with-latex] [--all]
#
# User-level installs go to ~/.local (bin/, opt/, share/fonts); sudo is only used for distro packages.
# NVIM_CONFIG_REPO overrides the clone source (e.g. a local path when testing).
set -euo pipefail
ORIGINAL_PATH=$PATH

REPO=${NVIM_CONFIG_REPO:-https://github.com/tudor38/kickstart.nvim.git}
PUSH_URL=git@github.com:tudor38/kickstart.nvim.git
CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/nvim
BIN=$HOME/.local/bin
OPT=$HOME/.local/opt

NVIM_MIN=0.12.0
TREE_SITTER_MIN=0.26.1
GO_MIN=1.24.0 # gopls built by mason needs a recent toolchain
NERD_FONT=JetBrainsMono

# Everything below runs from main, so `curl | bash` reads the whole script before anything runs
main() {
WITH_OLLAMA=0 WITH_QUARTO=0 WITH_LATEX=0
for arg in "$@"; do
  case $arg in
    --with-ollama) WITH_OLLAMA=1 ;;
    --with-quarto) WITH_QUARTO=1 ;;
    --with-latex) WITH_LATEX=1 ;;
    --all) WITH_OLLAMA=1 WITH_QUARTO=1 WITH_LATEX=1 ;;
    -h | --help)
      echo 'usage: install.sh [--with-ollama] [--with-quarto] [--with-latex] [--all]'
      exit 0
      ;;
    *) echo "unknown option: $arg" >&2 && exit 2 ;;
  esac
done

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m    %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# version_ge A B: A >= B (dotted versions)
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }
# First x.y.z in a command's output, or 0
version_of() { "$@" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1 || true; }

# Latest release tag of a GitHub repo, without the leading v
latest_tag() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" | grep -oE '"tag_name": *"[^"]+"' | cut -d'"' -f4 | sed 's/^v//'
}

case $(uname -m) in
  x86_64 | amd64) ARCH=x86_64 GOARCH=amd64 TS_ARCH=x64 ;;
  aarch64 | arm64) ARCH=arm64 GOARCH=arm64 TS_ARCH=arm64 ;;
  *) echo "unsupported architecture: $(uname -m)" >&2 && exit 1 ;;
esac

mkdir -p "$BIN" "$OPT"
export PATH="$BIN:$HOME/.local/go/bin:$PATH"

SUDO=
[ "$(id -u)" -ne 0 ] && SUDO=sudo

# --- 1. Distro packages ------------------------------------------------------------------------------
step 'System packages'
need_node=0
have node || need_node=1
# Skip the package manager (and sudo) when everything is already there, e.g. when re-running to sync
missing=0
for cmd in git curl tar unzip gzip make gcc rg fc-cache python3 node npm; do have "$cmd" || missing=1; done
{ have fd || have fdfind; } || missing=1
# Debian splits venv (with ensurepip, which mason's Python tools need) into python3-venv
python3 -c 'import ensurepip' 2>/dev/null || missing=1
if ((!missing)); then
  info 'have them'
elif have apt-get; then
  pkgs=(git curl tar unzip gzip make gcc ripgrep fd-find fontconfig python3 python3-venv python3-pip)
  ((need_node)) && pkgs+=(nodejs npm)
  $SUDO apt-get update -qq
  DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y -qq "${pkgs[@]}" >/dev/null
elif have dnf; then
  pkgs=(git curl tar unzip gzip make gcc ripgrep fd-find fontconfig python3 python3-pip)
  ((need_node)) && pkgs+=(nodejs npm)
  $SUDO dnf install -y -q "${pkgs[@]}" >/dev/null
elif have pacman; then
  pkgs=(git curl tar unzip gzip make gcc ripgrep fd fontconfig python python-pip)
  ((need_node)) && pkgs+=(nodejs npm)
  # -Syu, not -Sy: refreshing without upgrading is a partial upgrade, which Arch doesn't support
  $SUDO pacman -Syu --needed --noconfirm "${pkgs[@]}" >/dev/null
elif have zypper; then
  pkgs=(git curl tar unzip gzip make gcc ripgrep fd fontconfig python3 python3-pip)
  ((need_node)) && pkgs+=(nodejs npm)
  $SUDO zypper --non-interactive install "${pkgs[@]}"
else
  warn 'No supported package manager (apt, dnf, pacman, zypper). Install these yourself:'
  warn 'git curl tar unzip make gcc ripgrep fd fontconfig python3 (+venv, pip) nodejs npm'
fi

# --- 2. Neovim -------------------------------------------------------------------------------------------
step "Neovim >= $NVIM_MIN"
current=$(version_of nvim --version)
if [ -n "$current" ] && version_ge "$current" "$NVIM_MIN"; then
  info "have $current"
else
  info 'installing the latest release'
  rm -rf "$OPT/nvim" && mkdir -p "$OPT/nvim"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$ARCH.tar.gz" |
    tar -xz -C "$OPT/nvim" --strip-components=1
  ln -sf "$OPT/nvim/bin/nvim" "$BIN/nvim"
  hash -r
  info "installed $(version_of nvim --version)"
fi

# --- 3. tree-sitter CLI ----------------------------------------------------------------------------------
step "tree-sitter CLI >= $TREE_SITTER_MIN"
current=$(version_of tree-sitter --version)
if [ -n "$current" ] && version_ge "$current" "$TREE_SITTER_MIN"; then
  info "have $current"
else
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$TS_ARCH.gz" |
    gunzip >"$BIN/tree-sitter"
  chmod +x "$BIN/tree-sitter"
  info "installed $(version_of tree-sitter --version)"
fi

# --- 4. lazygit ------------------------------------------------------------------------------------------
step 'lazygit'
if have lazygit; then
  info "have $(version_of lazygit --version)"
else
  tag=$(latest_tag jesseduffield/lazygit)
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v$tag/lazygit_${tag}_linux_$ARCH.tar.gz" |
    tar -xz -C "$BIN" lazygit
  info "installed $tag"
fi

# --- 5. Go -----------------------------------------------------------------------------------------------
step "Go >= $GO_MIN"
current=$(version_of go version)
if [ -n "$current" ] && version_ge "$current" "$GO_MIN"; then
  info "have $current"
else
  release=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)
  rm -rf "$HOME/.local/go"
  curl -fsSL "https://go.dev/dl/$release.linux-$GOARCH.tar.gz" | tar -xz -C "$HOME/.local"
  hash -r
  info "installed $release into ~/.local/go"
fi

# --- 6. Nerd Font ----------------------------------------------------------------------------------------
step "$NERD_FONT Nerd Font"
FONTS=$HOME/.local/share/fonts/$NERD_FONT
if [ -d "$FONTS" ]; then
  info 'have it'
else
  mkdir -p "$FONTS"
  tmp=$(mktemp)
  curl -fsSL -o "$tmp" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$NERD_FONT.zip"
  unzip -qo "$tmp" -d "$FONTS" '*.ttf'
  rm -f "$tmp"
  have fc-cache && fc-cache -f "$FONTS" >/dev/null
  info "installed; select \"$NERD_FONT Nerd Font\" in your terminal"
fi

# --- 7. Config -------------------------------------------------------------------------------------------
step "Config in $CONFIG"
if [ -d "$CONFIG/.git" ] && git -C "$CONFIG" remote -v | grep -q 'kickstart.nvim'; then
  if [ -n "$(git -C "$CONFIG" status --porcelain)" ]; then
    warn 'local changes; not pulling'
  else
    git -C "$CONFIG" pull --ff-only --quiet && info "up to date at $(git -C "$CONFIG" log -1 --format=%h)"
  fi
else
  if [ -e "$CONFIG" ]; then
    backup=$CONFIG.bak-$(date +%Y%m%d-%H%M%S)
    mv "$CONFIG" "$backup"
    warn "moved the existing config to $backup"
  fi
  git clone --quiet "$REPO" "$CONFIG"
  git -C "$CONFIG" remote set-url --push origin "$PUSH_URL"
  info "cloned $REPO"
fi

# --- 8. Optional extras ----------------------------------------------------------------------------------
if ((WITH_LATEX)); then
  step 'latex2text (math in Markdown)'
  have uv || curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
  if have latex2text; then info 'have it'; else uv tool install pylatexenc; fi
fi
if ((WITH_OLLAMA)); then
  step 'Ollama (gen.nvim)'
  if have ollama; then info 'have it'; else curl -fsSL https://ollama.com/install.sh | sh; fi
fi
if ((WITH_QUARTO)); then
  step 'Quarto'
  if have quarto; then
    info "have $(version_of quarto --version)"
  else
    case $ARCH in x86_64) QARCH=amd64 ;; arm64) QARCH=arm64 ;; esac
    tag=$(latest_tag quarto-dev/quarto-cli)
    rm -rf "$OPT/quarto" && mkdir -p "$OPT/quarto"
    curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v$tag/quarto-$tag-linux-$QARCH.tar.gz" |
      tar -xz -C "$OPT/quarto" --strip-components=1
    ln -sf "$OPT/quarto/bin/quarto" "$BIN/quarto"
    info "installed $tag"
  fi
fi

# --- 9. Plugins, parsers, mason tools --------------------------------------------------------------------
step 'Plugins, treesitter parsers, language servers (first run takes a few minutes)'
nvim --headless -l "$CONFIG/scripts/sync.lua" </dev/null

# --- 10. PATH --------------------------------------------------------------------------------------------
missing_path=()
for dir in "$BIN" "$HOME/.local/go/bin"; do
  [ -d "$dir" ] || continue
  case ":${ORIGINAL_PATH:-}:" in *":$dir:"*) ;; *) missing_path+=("$dir") ;; esac
done
if ((${#missing_path[@]})); then
  step 'Add to your shell rc'
  info "export PATH=\"$(
    IFS=:
    echo "${missing_path[*]}"
  ):\$PATH\""
fi

step 'Done'
}

main "$@"
