# Dotfiles

``` [shell]
sudo pacman -S git stow
git clone --recursive git@github.com:burberrymyshirt/dotfiles.git ${HOME}/.dotfiles
cd ${HOME}/.dotfiles
stow --dotfiles -t ${HOME} files
```

## XDG Base Directory

Remember to set XDG variables, otherwise some configurations might not work properly.
I prefer doing it in `/etc/security/pam_env.conf`

Append the following to that file: 

``` [shell]
XDG_CACHE_HOME   DEFAULT=@{HOME}/.cache
XDG_CONFIG_HOME  DEFAULT=@{HOME}/.config
XDG_DATA_HOME    DEFAULT=@{HOME}/.local/share
XDG_STATE_HOME   DEFAULT=@{HOME}/.local/state
```

## Suckless

Choose the correct branches for the suckless submodules, as they are sometimes wrong as a consequence of my sometimes sporadic changes.

## Dependencies

### Font

Everything uses a Nerd Font from nerdfonts.com
To install them all:

``` [shell]
sudo pacman -S nerd-fonts
```

### Bashrc

These are the programs i use, which are initialized in the bashrc, and will print errors to stdout if not present:

``` [shell]
sudo pacman -S zoxide keychain
```

### Neovim

Open neovim and run the command `:checkhealth`. Then fix all the relevant errors.

### Tmux

For tmux, remember to run this command to manually clone the package manager. Only first time setup:

``` [shell]
git clone https://github.com/tmux-plugins/tpm ${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm
```

Then run `<C-Space>I` inside tmux to install all plugins.
