#!/bin/bash

set -e

info() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

# 1. Install Homebrew
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_BIN=$(command -v brew)
  echo "eval \"\$($BREW_BIN shellenv)\"" >> ~/.zprofile
  eval "$($BREW_BIN shellenv)"
else
  info "Homebrew already installed."
  BREW_BIN=$(command -v brew)
  eval "$($BREW_BIN shellenv)"
fi

# 2. Install Python via Homebrew
if ! command -v python3 &>/dev/null; then
  info "Installing Python via Homebrew..."
  brew install python
else
  info "Homebrew Python already installed."
fi

# Ensure pip is up to date (use --user to avoid permission issues)
python3 -m pip install --upgrade --user pip

# 3. Install pyenv and latest stable Python version
if ! command -v pyenv &>/dev/null; then
  info "Installing pyenv..."
  brew install pyenv
  # Avoid duplicating lines by checking before append
  if ! grep -q "pyenv config" ~/.zshrc; then
    echo -e '\n# pyenv config' >> ~/.zshrc
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
  fi
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
else
  info "pyenv already installed."
fi

info "Installing latest stable Python with pyenv..."
LATEST_PYTHON=$(pyenv install --list | grep -E '^\s*3\.[0-9]+\.[0-9]+$' | tail -1 | xargs)
pyenv install -s "$LATEST_PYTHON"
pyenv global "$LATEST_PYTHON"

# 4. Install Miniconda
if ! command -v conda &>/dev/null; then
  info "Installing Miniconda..."
  ARCH=$(uname -m)
  if [ "$ARCH" == "arm64" ]; then
    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
  else
    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
  fi
  curl -L -o ~/miniconda.sh "$CONDA_URL"
  bash ~/miniconda.sh -b -p "$HOME/miniconda"
  rm ~/miniconda.sh
  # Only add PATH line if not present
  if ! grep -q 'export PATH="$HOME/miniconda/bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.zshrc
  fi
  export PATH="$HOME/miniconda/bin:$PATH"
  # Only run conda init once
  if ! grep -q 'conda initialize' ~/.zshrc; then
    conda init zsh
  fi
else
  info "Conda already installed."
fi

# 5. Install Neovim
if ! command -v nvim &>/dev/null; then
  info "Installing Neovim..."
  brew install neovim
else
  info "Neovim already installed."
fi

# 6. Install Rust via rustup
if ! command -v rustc &>/dev/null; then
  info "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # Add Rust path to .zshrc only if missing
  if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
  fi
  export PATH="$HOME/.cargo/bin:$PATH"
else
  info "Rust already installed."
fi

# Install Oh My Zsh only if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  info "Oh My Zsh already installed."
fi

# Ensure .aliases is sourced from .zshrc (add if missing)
if ! grep -q 'source ~/.aliases' ~/.zshrc; then
  echo -e '\n# Source personal aliases\nif [ -f ~/.aliases ]; then\n  source ~/.aliases\nfi' >> ~/.zshrc
fi

# Install btop
info "Installing btop..."
brew install btop

echo "Setup complete!"

echo "Setting up Vim color schemes..."

# Create Vim theme directory
mkdir -p ~/.vim/pack/themes/start

# Install or update Vim themes
for theme in dracula tender; do
  dir="$HOME/.vim/pack/themes/start/$theme"
  repo="https://github.com/$theme/vim.git"
  # Special case for tender theme repo URL
  if [ "$theme" = "tender" ]; then
    repo="https://github.com/jacoborus/tender.vim.git"
  fi

  if [ -d "$dir" ]; then
    info "Updating $theme theme..."
    git -C "$dir" pull --quiet
  else
    info "Cloning $theme theme..."
    git clone "$repo" "$dir"
  fi
done

# Backup existing .vimrc if it exists and doesn't already contain dracula
VIMRC="$HOME/.vimrc"
if [ -f "$VIMRC" ] && ! grep -q "colorscheme dracula" "$VIMRC"; then
  info "Backing up existing .vimrc to .vimrc.bak"
  cp "$VIMRC" "$VIMRC.bak"
fi

# Write .vimrc if not already containing dracula colorscheme
if ! grep -q "colorscheme dracula" "$VIMRC"; then
  info "Creating ~/.vimrc with Dracula theme"
  cat <<EOF > "$VIMRC"
syntax on
set number
set relativenumber
set termguicolors
colorscheme dracula

" fallback if Dracula fails
if v:errmsg =~# 'Cannot find color scheme'
  colorscheme tender
endif
EOF
else
  info "~/.vimrc already contains theme config"
fi

echo "🔧 Configuring Git..."

# Prompt for Git identity
read -p "Enter your Git name: " git_name
read -p "Enter your Git email: " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"

git config --global core.editor "vim"
git config --global color.ui auto
git config --global init.defaultBranch main
git config --global pull.rebase false

echo "✅ Git configured!"

info "🔗 Symlinking dotfiles..."

DOTFILES_DIR="$HOME/mac-dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "❌ Dotfiles directory $DOTFILES_DIR does not exist. Aborting symlinks."
  exit 1
fi

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
ln -sf "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"

info "✅ Dotfiles symlinked."

# Install neofetch if not already installed
if ! command -v neofetch &>/dev/null; then
  info "Installing neofetch..."
  brew install neofetch
else
  info "neofetch already installed."
fi

info "✅ Done! Restart your terminal to load pyenv, conda, rust paths, and Oh My Zsh."

