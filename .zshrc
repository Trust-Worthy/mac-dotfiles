# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
neofetch

export NVM_DIR="$HOME/.nvm"
unalias rm 2>/dev/null
rm() {
  echo "⚠️  Are you sure you want to move these to trash: $@ ? (y/N)"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    trash "$@"
  else
    echo "🛑 Cancelled."
  fi
}

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if [ -x "$HOME/miniconda3/bin/conda" ]; then
  __conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
          . "$HOME/miniconda3/etc/profile.d/conda.sh"
      else
          export PATH="$HOME/miniconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup
fi

# <<< conda initialize <<<
export PATH="/opt/homebrew/bin:$PATH"
