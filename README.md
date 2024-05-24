# Dotfiles

``` [shell]
sudo pacman -S git stow
git clone --recursive git@github.com:burberrymyshirt/dotfiles.git ${HOME}/.dotfiles
cd ${HOME}/.dotfiles
stow --dotfiles -t ${HOME} files
```

## Dependencies

### Bashrc

``` [shell]
sudo pacman -S zoxide keychain
```

### Neovim

Open neovim and run command `:checkhealth`.


## Tmux

For tmux, remember to run this command to manually clone the package manager. Only first time setup:

``` [shell]
git clone https://github.com/tmux-plugins/tpm ${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm
```

And run `<C-Space>I` inside tmux to install all plugins.
