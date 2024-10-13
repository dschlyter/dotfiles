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

    local target="$settings_root/$settings_subdir/$settings_file"

    if [ -d "$settings_root" ]; then
        mkdir -p "${settings_root}/${settings_subdir}"
        bak_nonlink "$target"
        link "$dotfiles_file" "$target"
    else
        echo "$settings_root dir not found, skipping $target."
    fi
}

inject() {
    local inject="$1"
    local file="$2"
    local pos="${3:-last}"

    test -f "$file" || touch "$file"

    if grep -q -F "$inject" "$file"; then
        echo "file $file already contains '$inject'"
        return
    fi

    # create tmp file since reading and writing to the same with (without sponge) is bad
    local tmp_file="${file}.inject-bak"
    if [[ "$pos" == "first" ]]; then
        echo "$inject" > "$tmp_file"
        cat "$file" >> "$tmp_file"
    elif [[ "$pos" == "last" ]]; then
        cat "$file" > "$tmp_file"
        echo "$inject" >> "$tmp_file"
    else
        echo "Unsupported position $pos for $file inject"
        exit 1
    fi
    echo "injected $inject into $file"
    mv "$tmp_file" "$file"
}

link . .dotfiles
link bin

link .zshrc_base
link .zgen_plugins
# NOCOMMIT temp linking
link .bashrc_base
link .shellrc_base
link .kubectl_aliases

link .fasd.sh # autojump
link .vimrc
link .gitconfig .gitconfig_base
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

link_settings "$HOME/.config" ptpython config.py ptpython-config.py
link_settings "$HOME/.config" ptpython startup.py ptpython-startup.py

inject 'source "$HOME/.zshrc_base"' "$HOME/.zshrc" first
inject '# Note: Overrides below can be overridden again by anything in .zshrc_*, use .zshrc if this is a problem' "$HOME/.shellrc" first
inject 'source "$HOME/.shellrc_base"' "$HOME/.shellrc" first
inject 'source "$HOME/.bashrc_base"' "$HOME/.bashrc" first
inject '[include]
    path = .gitconfig_base' "$HOME/.gitconfig" first

case "$(uname -s)" in
    Darwin)
        echo "Detected Mac OSX"
        link .zshrc_mac
        # link .hammerspoon
        # make sure the local file exists since it will be loaded
        # touch .hammerspoon/init-local.lua

        intellij_prefs="$(printf '%s\n' "$HOME/Library/Application Support/JetBrains/"*Idea* | tail -n 1)"
        link_settings "$intellij_prefs" "keymaps" "intellij_mac_keys.xml"

        link_settings "$HOME/Library/Application Support/Code/" "User" "keybindings.json" "vscode_keybindings.json"
        # TODO is this a good idea ??
        # this might force local state into git, in that case copy part of the file using "between" cmd
        link_settings "$HOME/Library/Application Support/Code/" "User" "settings.json" "vscode_settings.json"
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

        intellij_prefs="$(printf '%s\n' "$HOME/.config/JetBrains/"*Idea* | tail -n 1)"
        link_settings "$intellij_prefs" "config/keymaps" "intellij_linux_keys.xml"
        link_settings "$HOME/.config/Code - OSS/" "User" "keybindings.json" "vscode_keybindings_linux.json"

        if grep microsoft /proc/version; then
            link .zshrc_linux_wsl
        fi
        ;;

    *)
        echo "!!! WARNING Unable to detect OS"
        ;;
esac

if [[ "$SHELL" == "/bin/zsh" ]]; then
    echo "zsh is the current active shell"
elif [[ -f /bin/zsh ]]; then
    if [[ "$*" != *"--no-zsh"* ]]; then
        read -p "Switch shell to zsh (skip check with --no-zsh)? [y/n]: " yn
        if [[ "$yn" == [Yy]* ]]; then
            chsh -s /bin/zsh
        fi
    else
        echo "Skipping zsh shell change"
    fi
else
    echo "zsh not found, please install and chsh manually"
fi

echo

if [[ "$*" == *"--all"* ]] || [[ "$*" == *"--zgen"* ]]; then
    echo "Initializing zgen"
    zg_dir="${HOME}/.zgen"
    test -d "$zg_dir" && rm -rf "$zg_dir"
    git clone https://github.com/tarjoilija/zgen.git "$zg_dir"
else
    echo "Not installing/updating zgen (zsh plugins), run with --zgen or --all to enable"
fi

if [[ "$*" == *"--all"* ]] || [[ "$*" == *"--fzf"* ]]; then
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    else
        cd ~/.fzf
        git pull
        cd "$DOTFILES"
    fi
    ~/.fzf/install --key-bindings --completion --no-update-rc
else
    echo "Not installing/updating fzf, run with --fzf or --all to enable"
fi

if [[ "$*" == *"--all"* ]] || [[ "$*" == *"--vundle"* ]]; then
    if ! [ -d ~/.vim/bundle/vundle ]; then
        echo "Installing vim vundle plugins"
        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    fi
    vim +PluginInstall +qall
    echo "Vundle plugins installed!"
else
    echo "Not installing vim vundle plugins, run with --vundle or --all to enable"
fi

if [[ "$*" == *"--all"* ]] || [[ "$*" == *"--tpm"* ]]; then
    which cmake || (echo "Cmake required for tpm cpu plugin"; exit 1)

    if ! [ -d ~/.tmux/plugins/tpm ]; then
        echo "Installing tmux tpm plugins"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    echo "Tpm plugins installed!"
else
    echo "Not installing tmux tpm plugins, run with --tpm or --all to enable"
fi

cron_add() {
    (crontab -l || true ; echo "$@") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
}

if [[ "$*" == *"--all"* ]] || [[ "$*" == *"--cron"* ]]; then
    echo "Adding autoupdate to cron"
    cron_add "0 10 * * * $HOME/bin/git-autoupdate >> /tmp/git-autoupdate-$USER.log 2>&1"
    echo "Setting up transient auto delete area"
    cron_add "0 14 * * * find $HOME/transient -mtime +14 -delete; mkdir -p $HOME/transient"
else
    echo "Not installing autoupdate/transient cron, run with --cron or --all to enable"
fi

if [[ "$*" == *"--git"* ]]; then
    git config --global user.name "David Schlyter"
    git config --global user.email "dschlyter@gmail.com"
else
    echo "Not configuring default git author info, run with --git to enable"
fi

# maintain the correct user for dotfiles regardless of global config
git config user.name "David Schlyter"
git config user.email "dschlyter@gmail.com"

if git remote get-url origin | grep -q "git@" || git remote get-url origin --push | grep -q http; then
    echo "Changing push url to use ssh, pull to use http"
    # set pull to http
    git remote set-url origin "$(git github-url)"
    # set push to ssh
    git github-use-ssh
fi
