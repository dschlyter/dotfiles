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
        OLD_TARGET="$(readlink -- "$SOURCE")"
        if [[ "$OLD_TARGET" != "$TARGET" ]]; then
            echo "!!! updating link $TARGET ($OLD_TARGET => $TARGET)"
            rm "$SOURCE"
            ln -s "$TARGET" "$SOURCE"
        fi
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

    if [[ -e "$SOURCE" && ! -L "$SOURCE" ]]; then
        echo "backing up non-linked $SOURCE"
        mv "$SOURCE" "${SOURCE}.dotfiles-bak"
    fi
}

link_settings() {
    local settings_root="$1"
    local settings_subdir="$2"
    local settings_file="$3"
    local dotfiles_file="${4:-$settings_file}"

    echo $settings_root

    local target="$settings_root/$settings_subdir/$settings_file"

    if [ -d "$settings_root" ]; then
        mkdir -p "${settings_root}/${settings_subdir}"
        bak_nonlink "$target"
        link "$dotfiles_file" "$target"
    else
        echo "$target preferences not found, skipping link."
    fi
}

link . .dotfiles
link bin

link .zshrc
link .zgen_plugins
bak_nonlink .bashrc
link .bashrc
link .shellrc
link .kubectl_aliases

link .fasd.sh # autojump
link .vimrc
link .gitconfig
link .gitignore_global .gitignore
link .git_template
link git-scripts .git-scripts
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
        # make sure the local file exists since it will be loaded
        touch .hammerspoon/init-local.lua

        intellij_prefs="$(echo "/Users/$USER/Library/Preferences/IntelliJIdea"* | xargs -n 1 echo | tail -n 1)"
        link_settings "$intellij_prefs" "keymaps" "intellij_mac_keys.xml"

        link_settings "/Users/$USER/Library/Application Support/Code/" "User" "keybindings.json" "vscode_keybindings.json"
        ;;

    CYGWIN*|MINGW32*|MSYS*)
        echo "Detected Windows/Cygwin"
        link .zshrc_cygwin
        link .z.sh # alt autojump that is faster on windows
        ;;

    Linux)
        echo "Detected Linux"
        link .zshrc_linux
        link .shellrc_linux
        # Linking individual files does not work so we hack around by linking the directory
        # This could be extracted to link_dir function if reuse is needed
        # Irrelevant files are ignored with .gitignore
        xfce_conf=.config/xfce4/xfconf/xfce-perchannel-xml
        if [[ -e "$HOME/$xfce_conf" ]]; then
            if [[ ! -L "$HOME/$xfce_conf" ]]; then
                (cp -n "$HOME/$xfce_conf/"* "$DOTFILES/$xfce_conf" || true)
                bak_nonlink $xfce_conf
                link $xfce_conf
            else
                echo "Xfce conf already linked"
            fi
        fi

        intellij_prefs="$(echo "$HOME/.IntelliJIdea"* | xargs -n 1 echo | tail -n 1)"
        link_settings "$intellij_prefs" "config/keymaps" "intellij_linux_keys.xml"

        ;;

    *)
        echo "!!! WARNING Unable to detect OS"
        ;;
esac

if ! [[ -f $HOME/.gitconfig_local ]]; then
    # Configuring git user name
    cp .gitconfig_local $HOME/.gitconfig_local
    ${EDITOR:-vi} $HOME/.gitconfig_local
fi

# maintain the correct user for dotfiles
git config user.name "David Schlyter"
git config user.email "dschlyter@gmail.com"

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

if [[ "$*" == *"--zgen"* ]]; then
    echo "Initializing zgen"
    zg_dir="${HOME}/.zgen"
    test -d "$zg_dir" && rm -rf "$zg_dir"
    git clone https://github.com/tarjoilija/zgen.git "$zg_dir"
else
    echo "Not installing/updating zgen (zsh plugins), run with --zgen to enable" 
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
    if ! [ -d ~/.vim/bundle/vundle ]; then
        echo "Installing vim vundle plugins"
        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    fi
    vim +PluginInstall +qall
    echo "Vundle plugins installed!"
else
    echo "Not installing vim vundle plugins, run with --vundle to enable"
fi

if [[ "$*" == *"--tpm"* ]]; then
    which cmake || (echo "Cmake required for tpm cpu plugin"; exit 1)

    if ! [ -d ~/.tmux/plugins/tpm ]; then
        echo "Installing tmux tpm plugins"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    echo "Tpm plugins installed!"
else
    echo "Not installing tmux tpm plugins, run with --tpm to enable"
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
