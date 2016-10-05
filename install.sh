#!/bin/bash

set -euo pipefail

DOTFILES="$(pwd)"

link() {
   FILE="$1"
   SOURCE="$HOME/${2:-$FILE}"
   TARGET="$DOTFILES/$FILE"

   if [ -L "$SOURCE" ]; then
       echo "file $FILE already linked"
   elif [ -e "$SOURCE" ]; then
       echo "!!! ERROR file $FILE exists but is not a link"
   else
       echo "linking $TARGET"
       ln -s "$TARGET" "$SOURCE"
   fi
}

bak_nonlink() {
   FILE="$1"
   SOURCE="$HOME/$FILE"
   if [[ -f "$SOURCE" && ! -L "$SOURCE" ]]; then
       echo "backing up non-linked file $SOURCE"
       mv "$SOURCE" "${SOURCE}.bak"
   fi
}

link . dotfiles
link bin

link .zshrc
bak_nonlink .bashrc
link .bashrc
link .shellrc
link .kubectl_aliases

link .fasd.sh # autojump
link .vimrc
link .gitconfig
link .gitignore
link .git_template

mkdir -p "$HOME/.vim"
link .vim/colors
link .ideavimrc
link .percol.d
link .tmux.conf

case "$(uname -s)" in
    Darwin)
        echo "Detected Mac OSX"
        link .zshrc_mac
        link .hammerspoon
        ;;

    CYGWIN*|MINGW32*|MSYS*)
        echo Detected Windows/Cygwin
        link .zshrc_cygwin
        link .z.sh # alt autojump that is faster on windows
        ;;

    Linux)
        echo Detected Linux
        ;;

    *)
        echo Unable to detect OS
        ;;
esac

if [ "$SHELL" == "/bin/zsh" ]; then
    echo zsh is the current active shell
elif [ -f /bin/zsh ]; then
    chsh -s /bin/zsh
else
    echo zsh not found, please install and chsh manually
fi

if [[ "$@" == *"--vundle"* ]]; then
    echo "Installing vim vundle plugins"
    if ! [ -d ~/.vim/bundle/vundle ]; then
        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    fi
    vim +PluginInstall +qall
    echo "Plugins installed!"
else
    echo "Not installing vim vundle plugins, run with --vundle to enable"
fi
