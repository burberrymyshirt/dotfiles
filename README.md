# Dotfiles

``` [shell]
sudo pacman -S git stow
git clone --recursive git@github.com:burberrymyshirt/dotfiles.git ${HOME}/.dotfiles
cd ./.dotfiles/
stow --dotfiles -t ${HOME} files
```
