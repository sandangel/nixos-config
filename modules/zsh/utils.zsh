function pbcopy() {
  if [[ $(uname -s) == *"Darwin"* ]]; then
    command pbcopy $1
  else
    cat - | wl-copy
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
  local main_branch
  if [[ $(git remote show origin | sed -n '/HEAD branch/s/.*: //p') == "main" ]]; then
    main_branch="main"
  else
    main_branch="master"
  fi

  local current_worktree=$(git rev-parse --show-toplevel)
  local main_worktree=$(git worktree list | head -1 | awk '{print $1}')

  # Pull main wherever it's checked out (avoids "already used by worktree" error)
  local main_branch_wt=$(git worktree list | grep "\[${main_branch}\]$" | awk '{print $1}')
  if [[ -n "$main_branch_wt" ]]; then
    git -C "$main_branch_wt" pull
  else
    git -C "$main_worktree" checkout "$main_branch"
    git -C "$main_worktree" pull
  fi

  local current_branch=$(git branch --show-current)
  local dest="${main_branch_wt:-$main_worktree}"

  _gdmb_cleanup_empty_parents() {
    local path="$1" root="$2"
    local dir=$(dirname "$path")
    while [[ "$dir" != "$root" ]] && [[ "$dir" == "$root"/* ]]; do
      rmdir "$dir" 2>/dev/null || break
      dir=$(dirname "$dir")
    done
  }

  local current_branch=$(git branch --show-current)
  local dest="${main_branch_wt:-$main_worktree}"

  if [[ "$current_worktree" != "$main_worktree" ]] && [[ "$current_branch" != "$main_branch" ]]; then
    cd "$dest"
    git worktree remove --force "$current_worktree"
    _gdmb_cleanup_empty_parents "$current_worktree" "$main_worktree"
    git branch -D "$current_branch"
  else
    local pruned=$(git -C "$main_worktree" remote prune origin | sed "s/^.*origin\///g" | sort)
    local merged_branches=$(comm -12 <(git branch | sed "s/ *//g" | sort) <(echo "$pruned"))
    while IFS= read -r branch; do
      [[ -z "$branch" ]] && continue
      local wt_path="$main_worktree/$branch"
      if git worktree list | awk '{print $1}' | grep -qxF "$wt_path"; then
        git worktree remove --force "$wt_path"
        _gdmb_cleanup_empty_parents "$wt_path" "$main_worktree"
      fi
      git branch -D "$branch"
    done <<< "$merged_branches"
  fi
}

function krj() {
  kubectl get job $@ -o json | jq 'del(.spec.selector)' | jq 'del(.spec.template.metadata.labels)' | kubectl replace --force -f -
}

function gwt-add() {
  local root=$(git worktree list | head -1 | awk '{print $1}')
  git worktree add "$root/$1" -b "$1" origin/main && cd "$root/$1"
}

function gwt-rm() {
  local root=$(git worktree list | head -1 | awk '{print $1}')
  git worktree remove "$root/$1" && git branch -D "$1"
}
