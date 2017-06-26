#!/bin/bash

set -euo pipefail

pushd `dirname $0` > /dev/null
DOTFILES=`pwd`
popd > /dev/null

link() {
    FILE="$1"
    SOURCE="${2:-$FILE}"
    if [[ ! $SOURCE == /** ]]; then
        SOURCE="$HOME/$SOURCE"
    fi
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
    SOURCE="$1"
    if [[ ! $SOURCE == /** ]]; then
        SOURCE="$HOME/$SOURCE"
    fi

    if [[ -f "$SOURCE" && ! -L "$SOURCE" ]]; then
        echo "backing up non-linked file $SOURCE"
        mv "$SOURCE" "${SOURCE}.bak"
    fi
}

link . .dotfiles
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
link .agignore

mkdir -p "$HOME/.vim"
link .vim/colors
link .vim/spell
link .ideavimrc
link .tmux.conf
link .tmux-scripts

case "$(uname -s)" in
    Darwin)
        echo "Detected Mac OSX"
        link .zshrc_mac
        link .hammerspoon

        INTELLIJ_PREFS="$(echo /Users/$USER/Library/Preferences/IntelliJIdea* | xargs -n 1 echo | tail -n 1)"
        if [ -d "$INTELLIJ_PREFS" ]; then
            mkdir -p "$INTELLIJ_PREFS/keymaps"
            INTELLIJ_KEYMAP="intellij_mac_keys.xml"
            TARGET="$INTELLIJ_PREFS/keymaps/$INTELLIJ_KEYMAP"
            bak_nonlink "$TARGET"
            link "$INTELLIJ_KEYMAP" "$TARGET"
        else
            echo $INTELLIJ_PREFS
            echo "IntelliJ preferences not found, skipping."
        fi
        ;;

    CYGWIN*|MINGW32*|MSYS*)
        echo "Detected Windows/Cygwin"
        link .zshrc_cygwin
        link .z.sh # alt autojump that is faster on windows
        ;;

    Linux)
        echo "Detected Linux"
        link .shellrc_linux
        ;;

    *)
        echo "!!! WARNING Unable to detect OS"
        ;;
esac

if [ "$SHELL" == "/bin/zsh" ]; then
    echo "zsh is the current active shell"
elif [ -f /bin/zsh ]; then
    if [[ "$*" != *"--no-zsh"* ]]; then
        chsh -s /bin/zsh
    else
        echo "Skipping zsh shell change"
    fi
else
    echo "zsh not found, please install and chsh manually"
fi

if [[ "$*" == *"--sub"* ]]; then
    echo "Initializing submodules."
    git submodule init
    git submodule update
else
    echo "Not installing/updating submodules (syntax highlighting), run with --sub to enable"
fi

if [[ "$*" == *"--fzf"* ]]; then
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    else
        cd ~/.fzf
        git pull
        cd "$DOTFILES"
    fi
    ~/.fzf/install --key-bindings --completion --no-update-rc
else
    echo "Not installing/updating fzf, run with --fzf to enable"
fi

if [[ "$*" == *"--vundle"* ]]; then
    echo "Installing vim vundle plugins"
    if ! [ -d ~/.vim/bundle/vundle ]; then
        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    fi
    vim +PluginInstall +qall
    echo "Plugins installed!"
else
    echo "Not installing vim vundle plugins, run with --vundle to enable"
fi

cron_add() {
    (crontab -l || true ; echo "$@") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
}

if [[ "$*" == *"--cron"* ]]; then
    echo "Adding autoupdate to cron"
    cron_add "0 10 * * * $HOME/bin/git-autoupdate >> /tmp/git-autoupdate-$USER.log 2>&1"
else
    echo "Not installing autoupdate cron, run with --cron to enable"
fi
