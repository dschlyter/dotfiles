#!/bin/zsh

# jump with fasd using fzf filtering
fj() {
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 -e --no-sort +m)" && cd "${dir}" || return 1
}

cf() {
    local dir
    dir="$(find ${1:-} -type d | fzf -1 -0 -e --no-sort +m)" && cd "${dir}" || return 1
}

# vim with fasd
vf() {
  # zsh demon black magic here
  files=$(fasd -Rdl "$1" | fzf -0 -m) && $EDITOR ${(@f)files}
}

vc() {
  files=$(find . | fzf -0 -m) && $EDITOR ${(@f)files}
}

ic() {
  files=$(find . | fzf -0 -m) && open -a "IntelliJ IDEA" ${(@f)files}
}

# this is awesome :D - inject recently used files from fasd onto CLI filtering with fzf search
# this code is mostly copied and tweaked from .fzf/shell/completion.zsh for Ctrl-T
__fasdsel() {
  local cmd="${FZF_CTRL_F_COMMAND:-"fasd -l"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd | $(__fzfcmd) -m $FZF_CTRL_F_OPTS" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

fzf-file-fasd-widget() {
  LBUFFER="${LBUFFER}$(__fasdsel)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

zle     -N   fzf-file-fasd-widget
bindkey '^F' fzf-file-fasd-widget

# grab stuff from previous command, like filenames from find/ag or ip-addresses from ipconfig
__last_command_sel() {
    if [[ -n "$TMUX" ]]; then
      # use tmux buffer if available. skip the current line and newline from command
      local buffer="$(tmux capture-pane -p | head -n -1)"
    else
      # fallback - rerun last command
      # WARNING: this will re-run the last command, so be careful with destructive or long-running commands
      local last_command="$(fc -l -nIL -1 -1)"
      local buffer="$($last_command)"
    fi

    # select with fzf twice, first on line, then on columns in selected lines
    # preserve the typed query between runs
    local first_select="$(echo "$buffer" | fzf -m --tac --print-query $FZF_CTRL_G_OPTS)"
    local query="$(echo "$first_select" | head -n 1)"
    local selected_lines="$(echo "$first_select" | tail -n +2)"
    if [[ -z "$selected_lines" ]]; then
      return
    fi
    # we might want to select all in this case - try a very hacky way to put the cursor on top - in order to allow for tab+tab+tab to select
    local selected_items="$(echo "$selected_lines" | tr " " "\n" | grep -v "^$" | fzf -1 --tac -q "$query" -m --bind 'start:up+up+up+up+up+up+up+up+up+up+up+up+up+up+up+up+up' $FZF_CTRL_G_OPTS)"

    setopt localoptions pipefail 2> /dev/null
    echo "$selected_items" | while read item; do
        echo -n "${(q)item} "
    done
    local ret=$?
    echo
    return $ret
}

fzf-last-command-widget() {
    LBUFFER="${LBUFFER}$(__last_command_sel)"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}

zle     -N   fzf-last-command-widget
bindkey '^G' fzf-last-command-widget

# ftpane - switch pane (@george-b) - from https://github.com/junegunn/fzf/wiki/examples
ftpane() {
  local panes current_window current_pane target target_window target_pane
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')

  target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

  target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
    tmux select-pane -t ${target_window}.${target_pane}
  else
    tmux select-pane -t ${target_window}.${target_pane} &&
    tmux select-window -t $target_window
  fi
}


