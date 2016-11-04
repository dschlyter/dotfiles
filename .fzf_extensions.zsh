#!/bin/zsh

# jump with fasd using zfz filtering
zj() {
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

# this is awesome :D - inject recently used files from fasd onto CLI filtering with fzf search
# this code is mostly copied and tweaked from .fzf/shell/completion.zsh for Ctrl-T
__fasdsel() {
  local cmd="${FZF_CTRL_F_COMMAND:-"fasd -fl"}"
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


