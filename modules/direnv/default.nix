{ ... }:
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.config = {
    global = {
      log_format = "-";
      log_filter = "^$";
    };
  };
  programs.direnv.stdlib = ''
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    declare -A direnv_layout_dirs
    direnv_layout_dir() {
        local hash path
        echo "''${direnv_layout_dirs[$PWD]:=$(
            hash="$(sha1sum - <<< "$PWD" | head -c40)"
            path="''${PWD//[^a-zA-Z0-9]/}"
            echo "$XDG_CACHE_HOME/direnv/layouts/$hash-$path"
        )}"
    }

    use_flake() {
      watch_file flake.nix
      watch_file flake.lock
      eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
    }

    layout_poetry() {
      if has poetry; then
        if [[ ! -f pyproject.toml ]]; then
          echo 'No pyproject.toml found. Use `poetry init` to create one first.'
          poetry init
        fi

        # create venv if it doesn't exist
        poetry run true

        export VIRTUAL_ENV=$(poetry env info --path)
        export POETRY_ACTIVE=1
        PATH_add "$VIRTUAL_ENV/bin"
      fi
    }

    layout_pdm() {
      if has pdm; then
        # create venv if it doesn't exist
        if [[ ! -d .venv ]]; then
          pdm venv create
        fi

        if [[ ! -f pyproject.toml ]]; then
          echo 'No pyproject.toml found. Use `pdm init` to create one first.'
          pdm init
        fi

        if [[ "$VIRTUAL_ENV" == "" ]]; then
          pdm use -q --venv in-project
          eval $(pdm venv activate in-project)

          export VIRTUAL_ENV=$(pwd)/.venv
          export PYTHONPATH=$VIRTUAL_ENV/lib/$(command ls $VIRTUAL_ENV/lib | head -1)/site-packages:$PYTHONPATH
          PATH_add "$VIRTUAL_ENV/bin"
        fi
      fi
    }
  '';
}
