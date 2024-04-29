{
  lib,
  stdenv,
  pkgs,
  ...
}:

let
  custom = ./custom;
in
stdenv.mkDerivation rec {
  pname = "nvchad";
  version = "2.0";

  src = builtins.fetchGit {
    url = "https://github.com/NvChad/NvChad";
    ref = "refs/heads/v${version}";
  };

  init = pkgs.writeText "init.lua" (
    ''
      vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/${
        if stdenv.isLinux then "libsqlite3.so" else "libsqlite3.dylib"
      }'
    ''
    + builtins.readFile ./custom/init.lua
  );

  installPhase = ''
    mkdir $out
    cp -r * "$out/"
    mkdir -p "$out/lua/custom"
    cp -r ${custom}/* "$out/lua/custom/"
    # Override init.lua with init file that has sqlite_clib_path
    cp -f $init "$out/lua/custom/init.lua"
  '';

  meta = with lib; {
    description = "NvChad";
    homepage = "https://github.com/NvChad/NvChad";
    platforms = platforms.all;
    license = licenses.gpl3;
  };
}
