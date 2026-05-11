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

function _git_default_branch() {
  local branch
  branch=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  branch="${branch#origin/}"

  if [[ -z "$branch" ]]; then
    branch=$(git remote show origin 2>/dev/null | sed -n '/HEAD branch/s/.*: //p')
  fi

  if [[ -z "$branch" ]]; then
    if git show-ref --verify --quiet refs/heads/main; then
      branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
      branch="master"
    else
      branch="main"
    fi
  fi

  print -r -- "$branch"
}

function _git_primary_worktree() {
  git worktree list --porcelain | awk '/^worktree / { print substr($0, 10); exit }'
}

function _git_worktree_for_branch() {
  local branch="$1"
  git worktree list --porcelain | awk -v branch="refs/heads/$branch" '
    /^worktree / { path = substr($0, 10) }
    /^branch / {
      if (substr($0, 8) == branch) {
        print path
        exit
      }
    }
  '
}

function _git_protected_branch() {
  local branch="$1"
  local main_branch="$2"
  [[ -z "$branch" || "$branch" == "$main_branch" || "$branch" == "main" || "$branch" == "master" ]]
}

function _git_cleanup_empty_parents() {
  local target_path="$1" root="$2"
  local dir=$(dirname "$target_path")
  while [[ "$dir" != "$root" ]] && [[ "$dir" == "$root"/* ]]; do
    rmdir "$dir" 2>/dev/null || break
    dir=$(dirname "$dir")
  done
}

function _git_delete_branch() {
  local branch="$1"
  local main_branch="$2"
  local root="$3"

  if _git_protected_branch "$branch" "$main_branch"; then
    echo "refusing to delete protected branch: $branch" >&2
    return 0
  fi

  git -C "$root" branch -D "$branch"
}

function _git_branch_ready_to_delete() {
  local branch="$1"
  local main_branch="$2"
  local root="$3"
  local upstream

  git -C "$root" merge-base --is-ancestor "$branch" "$main_branch" 2>/dev/null && return 0

  upstream=$(git -C "$root" for-each-ref --format='%(upstream:short)' "refs/heads/$branch")
  [[ -n "$upstream" ]] || return 1

  ! git -C "$root" show-ref --verify --quiet "refs/remotes/$upstream"
}

function gdmb() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "gdmb: not inside a git worktree" >&2
    return 1
  fi

  local main_branch=$(_git_default_branch)
  local current_worktree=$(git rev-parse --show-toplevel)
  local primary_worktree=$(_git_primary_worktree)
  local current_branch=$(git branch --show-current)

  if [[ -z "$current_worktree" || -z "$primary_worktree" ]]; then
    echo "gdmb: could not determine git worktree paths" >&2
    return 1
  fi

  if [[ -z "$current_branch" ]]; then
    echo "gdmb: current worktree is detached; refusing to delete a branch" >&2
    return 1
  fi

  # Pull main wherever it's checked out (avoids "already used by worktree" error)
  local main_branch_wt=$(_git_worktree_for_branch "$main_branch")
  local dest="${main_branch_wt:-$primary_worktree}"

  if [[ -n "$main_branch_wt" ]]; then
    git -C "$main_branch_wt" pull || return
  else
    git -C "$primary_worktree" checkout "$main_branch" || return
    git -C "$primary_worktree" pull || return
  fi

  if [[ "$current_worktree" != "$primary_worktree" ]]; then
    if _git_protected_branch "$current_branch" "$main_branch"; then
      cd "$dest" || return
      echo "gdmb: refusing to remove protected branch worktree: $current_branch" >&2
      return 0
    fi

    cd "$dest" || return
    git -C "$dest" remote prune origin >/dev/null 2>&1
    if ! _git_branch_ready_to_delete "$current_branch" "$main_branch" "$primary_worktree"; then
      echo "gdmb: refusing to remove unmerged branch worktree: $current_branch" >&2
      return 1
    fi

    git worktree remove --force "$current_worktree"
    _git_cleanup_empty_parents "$current_worktree" "$primary_worktree"
    _git_delete_branch "$current_branch" "$main_branch" "$primary_worktree"
  else
    local pruned=$(git -C "$primary_worktree" remote prune origin | sed -n "s/^.*origin\///p" | sort -u)
    local local_branches=$(git -C "$primary_worktree" for-each-ref --format='%(refname:short)' refs/heads | sort -u)
    local pruned_branches=$(comm -12 <(print -r -- "$local_branches") <(print -r -- "$pruned"))
    local gone_upstream_branches=$(git -C "$primary_worktree" for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads | sed -n 's/^\(.*\) \[gone\]$/\1/p' | sort -u)
    local merged_branches=$(git -C "$primary_worktree" for-each-ref --format='%(refname:short)' --merged "$main_branch" refs/heads | sort -u)
    local cleanup_branches=$(printf '%s\n%s\n%s\n' "$pruned_branches" "$gone_upstream_branches" "$merged_branches" | sed '/^$/d' | sort -u)

    while IFS= read -r branch; do
      [[ -z "$branch" ]] && continue

      if _git_protected_branch "$branch" "$main_branch"; then
        continue
      fi

      local wt_path=$(_git_worktree_for_branch "$branch")
      if [[ -n "$wt_path" ]]; then
        if [[ "$wt_path" == "$primary_worktree" ]]; then
          echo "gdmb: skipping branch checked out in primary worktree: $branch" >&2
          continue
        fi

        git worktree remove --force "$wt_path" || continue
        _git_cleanup_empty_parents "$wt_path" "$primary_worktree"
      fi

      _git_delete_branch "$branch" "$main_branch" "$primary_worktree"
    done <<< "$cleanup_branches"
  fi
}

function krj() {
  kubectl get job $@ -o json | jq 'del(.spec.selector)' | jq 'del(.spec.template.metadata.labels)' | kubectl replace --force -f -
}

function gwt-checkout() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "gwt-checkout: not inside a git worktree" >&2
    return 1
  fi

  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "usage: gwt-checkout <branch>" >&2
    return 1
  fi

  local root=$(_git_primary_worktree)
  local current_branch=$(git branch --show-current)
  local dest="$root/$branch"

  if [[ -z "$current_branch" ]]; then
    echo "gwt-checkout: current worktree is detached; checkout a branch first" >&2
    return 1
  fi

  if [[ -e "$dest" ]]; then
    echo "gwt-checkout: destination already exists: $dest" >&2
    return 1
  fi

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dest" "$branch" && cd "$dest"
  else
    git worktree add "$dest" -b "$branch" "$current_branch" && cd "$dest"
  fi
}

function gwt-rm() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "gwt-rm: not inside a git worktree" >&2
    return 1
  fi

  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "usage: gwt-rm <branch>" >&2
    return 1
  fi

  local root=$(_git_primary_worktree)
  local main_branch=$(_git_default_branch)

  if _git_protected_branch "$branch" "$main_branch"; then
    echo "gwt-rm: refusing to remove protected branch: $branch" >&2
    return 1
  fi

  local wt_path=$(_git_worktree_for_branch "$branch")
  wt_path="${wt_path:-$root/$branch}"

  if [[ "$wt_path" == "$root" ]]; then
    echo "gwt-rm: refusing to remove primary worktree: $wt_path" >&2
    return 1
  fi

  git worktree remove "$wt_path" && _git_cleanup_empty_parents "$wt_path" "$root" && git -C "$root" branch -D "$branch"
}
