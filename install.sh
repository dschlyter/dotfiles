#!/bin/bash

set -euo pipefail

DOTFILES="$(pwd)"

link() {
   cd "$HOME"
   SOURCE="$1"
   LINK="$DOTFILES/$1"

   if [ -L "$SOURCE" ]; then
       echo "file $SOURCE already linked"
   else
       echo "linking $LINK"
       ln -s "$LINK" "$SOURCE"
   fi
}

install_plist() {
    echo "installing plist $1"
    cd "$DOTFILES"
    cp "$1" "$HOME/Library/Preferences/$1"
}

link .zshrc
link .z.sh # autojump
link .vimrc
link .gitconfig
link .gitignore

if ! [ -e .vim ]; then
    mkdir .vim
fi
link .vim/colors
link .ideavimrc
link .percol.d
link .tmux.conf

case "$(uname -s)" in
    Darwin)
        echo "Detected Mac OSX"
        link .zshrc_mac
        link .hammerspoon
        install_plist com.googlecode.iterm2.plist
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
