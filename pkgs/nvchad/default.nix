{
  lib,
  stdenv,
  pkgs,
  ...
}:

let
  lua = ./lua;
in
stdenv.mkDerivation {
  pname = "nvchad";
  version = "2.5";

  init = pkgs.writeText "init.lua" (
    ''
      vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/${
        if stdenv.isLinux then "libsqlite3.so" else "libsqlite3.dylib"
      }'
    ''
    + builtins.readFile ./init.lua
  );

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir $out
    # Override init.lua with init file that has sqlite_clib_path
    cp $init "$out/init.lua"
    cp -r ${lua} "$out/lua"
  '';

  meta = with lib; {
    description = "NvChad";
    homepage = "https://github.com/NvChad/NvChad";
    platforms = platforms.all;
    license = licenses.gpl3;
  };
}
