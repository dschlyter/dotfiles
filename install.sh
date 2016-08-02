#!/bin/bash

set -euo pipefail

DOTFILES="$(pwd)"

link() {
   FILE="$1"
   SOURCE="$HOME/$FILE"
   LINK="$DOTFILES/$FILE"

   if [ -L "$SOURCE" ]; then
       echo "file $FILE already linked"
   else
       echo "linking $LINK"
       ln -s "$LINK" "$SOURCE"
   fi
}

link .zshrc
link .z.sh # autojump
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
else
    echo "Not installing vim vundle plugins, run with --vundle to enable"
fi
