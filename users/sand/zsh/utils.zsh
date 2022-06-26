function pbcopy() {
  if [[ $(uname -s) == *"Darwin"* ]]; then
    command pbcopy $1
  else
    wl-copy $1
  fi
}

function gflg() {
  local hash=$(git log --oneline --color | fzf --ansi --preview-window right:60% --preview 'echo {} | cut -c1-7 | xargs git show --color | delta --light' | awk '{print $1}')
  if [[ -n "$hash" ]]; then echo -ne "$hash" | pbcopy; fi
}

function gfcm() {
  local commitmsg=$(git log --oneline --color | fzf --ansi --preview-window right:60% --preview 'echo {} | cut -c1-7 | xargs git show --color | delta --light' | cut -d\  -f2-)
  if [[ -n "$commitmsg" ]]; then echo -ne "$commitmsg" | pbcopy; fi
}

function gfco() {
  local branch=$(git branch -a --color | fzf --ansi | awk '{print $1}')
  local strip_remote_branch="${branch/remotes\/origin\//}"
  git checkout $strip_remote_branch
}

function gdmb() {
  if [[ $(git remote show origin | sed -n '/HEAD branch/s/.*: //p') == "main" ]]; then
    git checkout main
  else
    git checkout master
  fi
  git pull
  if [[ "$(uname -s)" == "Darwin" ]]; then
    comm -12 <(git branch | sed "s/ *//g") <(git remote prune origin | sed "s/^.*origin\///g") | xargs -L1 -J % git branch -D %
  else
    comm -12 <(git branch | sed "s/ *//g" | sort) <(git remote prune origin | sed "s/^.*origin\///g" | sort) | xargs -r -I % git branch -D %
  fi
}
