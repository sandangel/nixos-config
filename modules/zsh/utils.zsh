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
  local fallback="$1"
  local primary

  primary=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree / { print substr($0, 10); exit }')
  print -r -- "${primary:-$fallback}"
}

function _git_is_primary_worktree() {
  local root git_dir git_common_dir

  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  git_dir=$(git rev-parse --absolute-git-dir 2>/dev/null) || return 1
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return 1

  [[ "$git_common_dir" == /* ]] || git_common_dir="$root/$git_common_dir"
  [[ "$git_dir" == "$git_common_dir" ]]
}

function _git_is_working_tree_path() {
  local target_path="$1"
  [[ "$(git -C "$target_path" rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]
}

function _git_main_named_worktree() {
  local main_branch="$1"
  local current_worktree="$2"
  local common_dir candidate

  common_dir=$(git -C "$current_worktree" rev-parse --git-common-dir 2>/dev/null) || return
  [[ "$common_dir" == /* ]] || common_dir="$current_worktree/$common_dir"
  candidate="$common_dir/$main_branch"

  if [[ -d "$candidate" ]] && _git_is_working_tree_path "$candidate"; then
    print -r -- "$candidate"
  fi
}

function _git_is_main_named_worktree() {
  local main_branch="$1"
  local current_worktree="$2"
  [[ "${current_worktree:t}" == "$main_branch" ]]
}

function _git_worktree_for_branch() {
  local branch="$1"
  local root="${2:-.}"

  git -C "$root" worktree list --porcelain 2>/dev/null | awk -v branch="refs/heads/$branch" '
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
  local worktree_path

  if _git_protected_branch "$branch" "$main_branch"; then
    echo "refusing to delete protected branch: $branch" >&2
    return 0
  fi

  worktree_path=$(_git_worktree_for_branch "$branch" "$root")
  if [[ -n "$worktree_path" ]]; then
    echo "skipping branch checked out in worktree: $branch ($worktree_path)" >&2
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

function _git_cleanup_merged_branches() {
  local root="$1"
  local main_branch="$2"
  local branch pruned local_branches pruned_branches gone_upstream_branches merged_branches cleanup_branches

  if git -C "$root" remote get-url origin >/dev/null 2>&1; then
    pruned=$(git -C "$root" remote prune origin | sed -n "s/^.*origin\///p" | sort -u)
  else
    pruned=""
  fi

  git -C "$root" worktree prune >/dev/null 2>&1

  local_branches=$(git -C "$root" for-each-ref --format='%(refname:short)' refs/heads | sort -u)
  pruned_branches=$(comm -12 <(print -r -- "$local_branches") <(print -r -- "$pruned"))
  gone_upstream_branches=$(git -C "$root" for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads | sed -n 's/^\(.*\) \[gone\]$/\1/p' | sort -u)
  merged_branches=$(git -C "$root" for-each-ref --format='%(refname:short)' --merged "$main_branch" refs/heads | sort -u)
  cleanup_branches=$(printf '%s\n%s\n%s\n' "$pruned_branches" "$gone_upstream_branches" "$merged_branches" | sed '/^$/d' | sort -u)

  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue
    _git_protected_branch "$branch" "$main_branch" && continue
    _git_delete_branch "$branch" "$main_branch" "$root"
  done <<< "$cleanup_branches"
}

function _git_copy_worktree_files() {
  local source_worktree="$1"
  local dest_worktree="$2"
  local wt rel
  local -a excludes

  if ! command -v rsync >/dev/null 2>&1; then
    echo "gwt-checkout: rsync is required to copy worktree files" >&2
    return 1
  fi

  excludes=(
    --exclude='.git'
    --exclude='node_modules/'
    --exclude='venv/'
    --exclude='.venv/'
  )

  while IFS= read -r wt; do
    [[ -z "$wt" || "$wt" == "$source_worktree" ]] && continue

    if [[ "$wt" == "$source_worktree"/* ]]; then
      rel="${wt#$source_worktree/}"
      excludes+=(--exclude="/$rel")
      excludes+=(--exclude="/$rel/***")
    fi
  done < <(git -C "$source_worktree" worktree list --porcelain | awk '/^worktree / { print substr($0, 10) }')

  rsync -a "${excludes[@]}" "$source_worktree/" "$dest_worktree/"
}

function _git_exclude_nested_worktree() {
  local root="$1"
  local dest="$2"
  local rel git_common_dir exclude_file

  [[ "$dest" == "$root"/* ]] || return 0

  rel="${dest#$root/}"
  git_common_dir=$(git -C "$root" rev-parse --git-common-dir)
  [[ "$git_common_dir" == /* ]] || git_common_dir="$root/$git_common_dir"
  exclude_file="$git_common_dir/info/exclude"

  mkdir -p "$(dirname "$exclude_file")"
  grep -qxF "/$rel/" "$exclude_file" 2>/dev/null || print -r -- "/$rel/" >> "$exclude_file"
}

function gdmb() {
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
    echo "gdmb: not inside a git working tree" >&2
    return 1
  fi

  local main_branch=$(_git_default_branch)
  local current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)
  local current_branch=$(git branch --show-current)

  if [[ -z "$current_worktree" ]]; then
    echo "gdmb: could not determine git worktree path" >&2
    return 1
  fi

  if [[ -z "$current_branch" ]]; then
    echo "gdmb: current worktree is detached; refusing to delete a branch" >&2
    return 1
  fi

  if [[ -d "$current_worktree/.git" ]] || _git_is_primary_worktree || _git_is_main_named_worktree "$main_branch" "$current_worktree"; then
    git -C "$current_worktree" checkout "$main_branch" || return
    git -C "$current_worktree" pull || return
    _git_cleanup_merged_branches "$current_worktree" "$main_branch"
    return
  fi

  local primary_worktree=$(_git_primary_worktree "$current_worktree")
  if [[ -z "$primary_worktree" ]]; then
    echo "gdmb: could not determine primary worktree path" >&2
    return 1
  fi

  # Pull main wherever it's checked out (avoids "already used by worktree" error)
  local main_branch_wt=$(_git_worktree_for_branch "$main_branch" "$current_worktree")
  local main_named_wt=$(_git_main_named_worktree "$main_branch" "$current_worktree")
  local dest="${main_branch_wt:-$main_named_wt}"

  if [[ -n "$main_branch_wt" ]]; then
    git -C "$main_branch_wt" pull || return
  elif [[ -n "$main_named_wt" ]]; then
    git -C "$main_named_wt" checkout "$main_branch" || return
    git -C "$main_named_wt" pull || return
  elif _git_is_working_tree_path "$primary_worktree"; then
    dest="$primary_worktree"
    git -C "$primary_worktree" checkout "$main_branch" || return
    git -C "$primary_worktree" pull || return
  else
    echo "gdmb: could not find a working tree for $main_branch" >&2
    return 1
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
  fi
}

function krj() {
  kubectl get job $@ -o json | jq 'del(.spec.selector)' | jq 'del(.spec.template.metadata.labels)' | kubectl replace --force -f -
}

function gwt-checkout() {
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
    echo "gwt-checkout: not inside a git working tree" >&2
    return 1
  fi

  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "usage: gwt-checkout <branch>" >&2
    return 1
  fi

  local source_worktree=$(git rev-parse --show-toplevel 2>/dev/null)
  local root=$(_git_primary_worktree "$source_worktree")
  local current_branch=$(git branch --show-current)
  local dest="$root/$branch"
  local stashed=0

  if [[ -z "$current_branch" ]]; then
    echo "gwt-checkout: current worktree is detached; checkout a branch first" >&2
    return 1
  fi

  if [[ -e "$dest" ]]; then
    echo "gwt-checkout: destination already exists: $dest" >&2
    return 1
  fi

  if [[ -n "$(git -C "$source_worktree" status --porcelain --untracked-files=all)" ]]; then
    git -C "$source_worktree" stash push --include-untracked -m "gwt-checkout: move changes to $branch" -- . ':(glob,exclude)**/node_modules/**' ':(glob,exclude)**/venv/**' ':(glob,exclude)**/.venv/**' || return
    stashed=1
  fi

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    if ! git worktree add "$dest" "$branch"; then
      (( stashed )) && git -C "$source_worktree" stash pop --index 'stash@{0}'
      return 1
    fi
  else
    if ! git worktree add "$dest" -b "$branch" "$current_branch"; then
      (( stashed )) && git -C "$source_worktree" stash pop --index 'stash@{0}'
      return 1
    fi
  fi

  _git_exclude_nested_worktree "$root" "$dest"

  if ! _git_copy_worktree_files "$source_worktree" "$dest"; then
    (( stashed )) && git -C "$source_worktree" stash pop --index 'stash@{0}'
    git worktree remove --force "$dest" >/dev/null 2>&1
    return 1
  fi

  if (( stashed )); then
    if ! git -C "$dest" stash apply --index 'stash@{0}'; then
      echo "gwt-checkout: failed to apply changes in $dest; changes remain in stash@{0}" >&2
      return 1
    fi

    git -C "$source_worktree" stash drop 'stash@{0}' >/dev/null || return
  fi

  cd "$dest"
}

function gwt-rm() {
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
    echo "gwt-rm: not inside a git working tree" >&2
    return 1
  fi

  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "usage: gwt-rm <branch>" >&2
    return 1
  fi

  local current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)
  local root=$(_git_primary_worktree "$current_worktree")
  local main_branch=$(_git_default_branch)

  if _git_protected_branch "$branch" "$main_branch"; then
    echo "gwt-rm: refusing to remove protected branch: $branch" >&2
    return 1
  fi

  local wt_path=$(_git_worktree_for_branch "$branch" "$current_worktree")
  wt_path="${wt_path:-$root/$branch}"

  if [[ "$wt_path" == "$root" ]]; then
    echo "gwt-rm: refusing to remove primary worktree: $wt_path" >&2
    return 1
  fi

  git worktree remove --force "$wt_path" && _git_cleanup_empty_parents "$wt_path" "$root" && git -C "$root" branch -D "$branch"
}
