#!/bin/bash

# Symlinks and installs all dotfiles on a machine
# Can run multiple times, and should update new links on subsequent runs

set -euo pipefail

ARGS="$* --"

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
        echo "✅ $FILE already linked"
        OLD_TARGET="$(readlink -- "$SOURCE")"
        if [[ "$OLD_TARGET" != "$TARGET" ]]; then
            echo "✨ updating link $TARGET ($OLD_TARGET => $TARGET)"
            rm "$SOURCE"
            ln -s "$TARGET" "$SOURCE"
        fi
    elif [ -e "$SOURCE" ]; then
        echo "❌ file $FILE exists but is not a link"
    else
        echo "✨ linking $TARGET"
        ln -s "$TARGET" "$SOURCE"
    fi
}

bak_nonlink() {
    SOURCE="$1"
    if [[ ! $SOURCE == /** ]]; then
        SOURCE="$HOME/$SOURCE"
    fi

    if [[ -e "$SOURCE" && ! -L "$SOURCE" ]]; then
        echo "✨ backing up non-linked $SOURCE"
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
        echo "🔹 $settings_root dir not found, skipping $target"
    fi
}

sync_settings() {
    local settings_root="$1"
    local settings_subdir="$2"
    local settings_file="$3"
    local dotfiles_file="${4:-$settings_file}"

    local target="$settings_root/$settings_subdir/$settings_file"

    if [ -d "$settings_root" ]; then
        mkdir -p "${settings_root}/${settings_subdir}"

        local mtime1=$([[ -f "$dotfiles_file" ]] && (stat -c %Y "$dotfiles_file" 2>/dev/null || stat -f %m "$dotfiles_file" 2>/dev/null) || echo 0)
        local mtime2=$([[ -f "$target" ]] && (stat -c %Y "$target" 2>/dev/null || stat -f %m "$target" 2>/dev/null) || echo 0)

        if [[ "$mtime1" -eq 0 && "$mtime2" -eq 0 ]]; then
            echo "🔹 neither $dotfiles_file nor $target exists - no sync"
        elif [[ "$mtime1" -gt "$mtime2" ]]; then
            echo "✨ $dotfiles_file -> $target ($(($mtime1 - $mtime2)) newer)"
            cp -p "$dotfiles_file" "$target"
        elif [[ "$mtime2" -gt "$mtime1" ]]; then
            echo "✨ $target -> $dotfiles_file ($(($mtime2 - $mtime1)) newer)"
            cp -p "$target" "$dotfiles_file"
        else
            echo "✅ $dotfiles_file = $target (same age)"
        fi
    else
        echo "🔹 $settings_root dir not found, skipping $target"
    fi
}

inject() {
    local inject="$1"
    local file="$2"
    local pos="${3:-last}"

    test -f "$file" || touch "$file"

    if grep -q -F "$inject" "$file"; then
        echo "✅ $file already contains '$inject'"
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
    echo "✨ injected $inject into $file"
    mv "$tmp_file" "$file"
}

has_flag() {
    local skip_msg="$1"
    shift
    for flag in "$@"; do
        if [[ "$ARGS" == *"$flag"* ]]; then
            return 0
        fi
    done
    echo "🔹 not $skip_msg, to enable run with one of: $*"
    return 1
}

link . .dotfiles
link bin

link .zshrc_base
link .zgen_plugins
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

if [ -d "$HOME/.claude" ]; then
    link AGENTS.base.md "$HOME"/.claude/AGENTS.base.md
    inject '@AGENTS.base.md' ""$HOME"/.claude/CLAUDE.md" first
    if has_flag "installing personal Claude preferences" --claude --all; then
        link AGENTS.personal.md "$HOME"/.claude/AGENTS.personal.md
        inject '@AGENTS.personal.md' ""$HOME"/.claude/CLAUDE.md" first
    fi
else
    echo "🔹 skipping claude conf - no .claude dir"
fi

if [ -d "$HOME/.claude/skills" ]; then
    for skill in "$DOTFILES"/skills/*; do
        skill_name="$(basename "$skill")"
        link "skills/$skill_name" "$HOME/.claude/skills/$skill_name"
    done
else
    echo "🔹 skipping claude conf skills - no .claude/skills dir"
fi

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

        if grep microsoft /proc/version > /dev/null; then
            link .zshrc_linux_wsl
            # scary windows character insertion
            winhome="$(cmd.exe /c "echo %USERPROFILE%" 2> /dev/null | tr -d '\r')"
            winhome="$(wslpath -u "$winhome")"
            sync_settings "${winhome}/AppData/Roaming/Code/User" "" "settings.json" "vscode_settings.json"
            sync_settings "${winhome}/AppData/Roaming/Code/User" "" "keybindings.json" "vscode_keybindings_linux.json"
        fi

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
                echo "✅ Xfce conf already linked"
            fi
        fi

        intellij_prefs="$(printf '%s\n' "$HOME/.config/JetBrains/"*Idea* | tail -n 1)"
        link_settings "$intellij_prefs" "config/keymaps" "intellij_linux_keys.xml"
        link_settings "$HOME/.config/Code - OSS/" "User" "keybindings.json" "vscode_keybindings_linux.json"
        ;;

    *)
        echo "⚠️  unable to detect OS"
        ;;
esac

if [[ "$SHELL" == "/bin/zsh" ]]; then
    echo "✅ zsh is the current active shell"
elif [[ -f /bin/zsh ]]; then
    if [[ "$*" != *"--no-zsh"* ]]; then
        read -p "Switch shell to zsh (skip check with --no-zsh)? [y/n]: " yn
        if [[ "$yn" == [Yy]* ]]; then
            chsh -s /bin/zsh
        fi
    else
        echo "🔹 skipping zsh shell change"
    fi
else
    echo "🔹 zsh not found, please install and chsh manually"
fi

echo

if has_flag "installing/updating zgen (zsh plugins)" --zgen --all; then
    echo "✨ initializing zgen"
    zg_dir="${HOME}/.zgen"
    test -d "$zg_dir" && rm -rf "$zg_dir"
    git clone https://github.com/tarjoilija/zgen.git "$zg_dir"
fi

if has_flag "installing/updating fzf" --fzf --all; then
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    else
        cd ~/.fzf
        git pull
        cd "$DOTFILES"
    fi
    ~/.fzf/install --key-bindings --completion --no-update-rc
fi

if has_flag "installing vim vundle plugins" --vundle --all; then
    if ! [ -d ~/.vim/bundle/vundle ]; then
        echo "✨ installing vim vundle plugins"
        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    fi
    vim +PluginInstall +qall
    echo "✨ vundle plugins installed"
fi

if has_flag "installing tmux tpm plugins" --tpm --all; then
    which cmake || (echo "Cmake required for tpm cpu plugin"; exit 1)

    if ! [ -d ~/.tmux/plugins/tpm ]; then
        echo "✨ installing tmux tpm plugins"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    echo "✨ tpm plugins installed"
fi

cron_add() {
    (crontab -l || true ; echo "$@") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
}

if has_flag "installing autoupdate/transient cron" --cron --all; then
    echo "✨ adding autoupdate to cron"
    cron_add "0 10 * * * $HOME/bin/git-autoupdate >> /tmp/git-autoupdate-$USER.log 2>&1"
    echo "✨ setting up transient auto delete area"
    cron_add "0 14 * * * find $HOME/transient -mtime +14 -delete; mkdir -p $HOME/transient"
fi

if has_flag "configuring default git author info" --git; then
    git config --global user.name "David Schlyter"
    git config --global user.email "dschlyter@gmail.com"
    echo "✨ updated git settings"
fi

# maintain the correct user for dotfiles regardless of global config
git config user.name "David Schlyter"
git config user.email "dschlyter@gmail.com"

if git remote get-url origin | grep -q "git@" || git remote get-url origin --push | grep -q http; then
    echo "✨ changing push url to use ssh, pull to use http"
    # set pull to http
    git remote set-url origin "$(git github-url)"
    # set push to ssh
    git github-use-ssh
fi
