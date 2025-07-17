#!/bin/bash

set -e

info() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

# 1. Install Homebrew
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew already installed."
fi

# 2. Install Python via Homebrew
if ! command -v python3 &>/dev/null; then
  info "Installing Python via Homebrew..."
  brew install python
else
  info "Homebrew Python already installed."
fi

# Ensure pip is up to date
python3 -m pip install --upgrade pip

# 3. Install pyenv and latest stable Python version
if ! command -v pyenv &>/dev/null; then
  info "Installing pyenv..."
  brew install pyenv
  echo -e '\n# pyenv config' >> ~/.zshrc
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
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
  bash ~/miniconda.sh -b -p $HOME/miniconda
  rm ~/miniconda.sh
  echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.zshrc
  export PATH="$HOME/miniconda/bin:$PATH"
  conda init zsh
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
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
  export PATH="$HOME/.cargo/bin:$PATH"
else
  info "Rust already installed."
fi

info "✅ Done! Restart your terminal to load pyenv, conda, and rust paths."
