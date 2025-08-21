# Dotfiles

The programs installed below, is a non-exhaustive list of dependencies. Everything might not work out of the box. The current roadmap will include every step in an initial setup script.

``` [shell]
sudo pacman -S --needed jq git stow nerd-fonts tmux cargo zoxide keychain ripgrep fzf base-devel unzip wget curl neovim shotgun hacksaw xclip bash-completion go markdownlint tree-sitter-cli
git clone --recursive git@github.com:burberrymyshirt/dotfiles.git ${HOME}/.dotfiles
cd ${HOME}/.dotfiles
stow --dotfiles -t ${HOME} files
```

Also make all scripts included executable:

``` [shell]
find ${HOME}/.dotfiles/files/dot-local/bin -type f -exec chmod +x {} \;
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

### Other dependencies
Other dependencies include asdf version manager, bash-complete-alias and paru. 
However none of them are hard dependenceis, they will just print erros in the terminal
