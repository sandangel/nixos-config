function nvim() {
  [[ -z $nvim_addr ]] && { command nvim ${@}; return }
  local window_id=$(kitty @ ls | jq -r '.[] | select(.is_focused == true).tabs[] | select(.is_focused == true).windows[] | select(.foreground_processes[].cmdline[0]== "nvim").id')
  [[ ! $window_id && -e $nvim_addr ]] && rm -rf $nvim_addr

  local session_folder="$HOME/.vim/sessions"
  local session_name="$session_folder/$(echo $(pwd) | sed "s|$HOME/||" | sed 's|/|.|g').vim"

  if [[ $# -eq 0 && ! $window_id && -f $session_name ]]; then
    command nvim -c "source $session_name" --listen $nvim_addr
  elif [[ $# -eq 0 && ! $window_id && ! -f $session_name && $PWD != $HOME ]]; then
    command nvim -c "mks $session_name" --listen $nvim_addr
  elif [[ $# -eq 0 && $window_id ]]; then
    kitty @ focus-window -m "id:$window_id" --no-response
  elif [[ $# -gt 0 && ! $window_id ]]; then
    command nvim --listen $nvim_addr $@
  elif [[ $# -gt 0 && $window_id ]]; then
    command nvim --server $nvim_addr --remote $@
    kitty @ focus-window -m "id:$window_id" --no-response
  else
    command nvim --listen $nvim_addr
  fi
}

function _bind_nvim_kitty() {
  cur_pid=$$
  if [[ $(uname -s) == *"Darwin"* ]]; then
    terminal_pid=$(ps -o ppid -p $cur_pid | tail -n +2 | tr -d '[:space:]')
    terminal=$(ps -o comm -p $terminal_pid | tail -n +2 | tr -d '[:space:]')
  else
    terminal_pid=$(ps -h -o ppid -p $cur_pid | tr -d '[:space:]')
    terminal=$(ps -h -o comm -p $terminal_pid | tr -d '[:space:]')
  fi

  if [[ $terminal == *"kitty"* ]]; then
    export nvim_addr=/tmp/nvim_kitty_tab_$(kitty @ ls | jq -r '.[] | select(.is_focused == true).tabs[] | select(.is_focused == true).id')
  fi
}

_bind_nvim_kitty
