zstyle ':z4h:'                start-tmux             'none'
zstyle ':z4h:'                term-vresize           'top'
zstyle ':z4h:'                prompt-at-bottom       'yes'
zstyle ':z4h:ssh:*'           enable                 'no'
zstyle ':z4h:direnv'          enable                 'no'
zstyle ':z4h:direnv:success'  notify                 'no'
zstyle ':z4h:'                term-shell-integration 'yes'
zstyle ':z4h:'                auto-update            'yes'
zstyle ':z4h:'                auto-update-days       '7'
zstyle ':z4h:'                propagate-cwd          'yes'
zstyle ':z4h:fzf-complete'    recurse-dirs           'yes'
zstyle ':z4h:fzf-complete'    fzf-bindings           tab:repeat
zstyle ':z4h:fzf-dir-history' fzf-bindings           tab:repeat
zstyle ':z4h:cd-down'         fzf-bindings           tab:repeat
# uses bfs by default
zstyle ':z4h:(cd-down|fzf-complete)' find-flags -exclude -name .git -exclude -name node_modules -name '.*' -prune -print -o -print

# Some of this is not documented
zstyle ':z4h:fzf' channel command "ln -s -- $__fzf_dir \$Z4H_PACKAGE_DIR"
function -z4h-postinstall-fzf() {}
zstyle ':z4h:Tarrasch/zsh-bd' postinstall "command cp \$Z4H_PACKAGE_DIR/{,zsh-}bd.plugin.zsh"
zstyle ':z4h:chisui/zsh-nix-shell' postinstall "command cp \$Z4H_PACKAGE_DIR/{,zsh-}nix-shell.plugin.zsh"

z4h install chisui/zsh-nix-shell
z4h install hlissner/zsh-autopair
z4h install Tarrasch/zsh-bd

z4h init || return

z4h load -c -- chisui/zsh-nix-shell hlissner/zsh-autopair Tarrasch/zsh-bd

z4h bindkey fzf-file-widget Ctrl+T
z4h bindkey z4h-fzf-dir-history Ctrl+F
z4h bindkey z4h-eof Ctrl+D

chpwd_functions=(${chpwd_functions[@]} "list_all")

setopt glob_dots
setopt auto_menu
setopt ignore_eof
setopt nonomatch
setopt no_flow_control
setopt extended_history
setopt hist_reduce_blanks
setopt hist_ignore_space

# smoother rendering
POSTEDIT=$'\n\n\e[2A'
