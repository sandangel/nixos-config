{
  lib,
  stdenv,
  makeWrapper,
  writeShellScript,
  coreutils,
  gawk,
  go,
  upstreamWails3,
}:

let
  script = writeShellScript "wails3-unwrapped" ''
    cache_dir="''${XDG_CACHE_HOME:-"$HOME/.cache"}/wails3"
    binary="$cache_dir/bin/wails3"
    version_file="$cache_dir/version"
    export GOMODCACHE="$cache_dir/go/pkg/mod"
    export GOCACHE="$cache_dir/go/build-cache"

    latest_beta="$(
      go list -m -mod=mod -versions github.com/wailsapp/wails/v3 |
        awk '{
          for (i = 2; i <= NF; i++) {
            if ($i ~ /^v3\.[0-9]+\.[0-9]+-beta\.[0-9]+$/) {
              split($i, parts, ".")
              if (parts[4] + 0 > highest) {
                highest = parts[4] + 0
                version = $i
              }
            }
          }
        }
        END {
          if (version == "") {
            exit 1
          }
          print version
        }'
    )"

    if [ ! -x "$binary" ] || [ ! -f "$version_file" ] || [ "$(cat "$version_file")" != "$latest_beta" ]; then
      mkdir -p "$(dirname "$binary")"
      GOBIN="$(dirname "$binary")" go install "github.com/wailsapp/wails/v3/cmd/wails3@$latest_beta"
      printf '%s\n' "$latest_beta" > "$version_file"
    fi

    exec "$binary" "$@"
  '';
in
stdenv.mkDerivation {
  pname = "wails3";
  version = "latest-beta";
  dontUnpack = true;

  # Keep the system dependencies and propagation behavior in sync with nixpkgs.
  nativeBuildInputs = upstreamWails3.nativeBuildInputs ++ [ makeWrapper ];
  buildInputs = upstreamWails3.buildInputs;
  propagatedBuildInputs = upstreamWails3.propagatedBuildInputs;
  depsTargetTargetPropagated = upstreamWails3.depsTargetTargetPropagated;

  installPhase = ''
    makeWrapper ${script} "$out/bin/wails3" \
      --prefix PATH : ${lib.makeBinPath [
        coreutils
        gawk
        go
      ]} \
      --prefix PKG_CONFIG_PATH : "$PKG_CONFIG_PATH"
  '';

  meta = {
    description = "Wails v3 CLI, automatically refreshed to the latest beta";
    homepage = "https://wails.io";
    license = lib.licenses.mit;
    mainProgram = "wails3";
    platforms = lib.platforms.linux;
  };
}
