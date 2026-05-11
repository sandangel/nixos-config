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
  pname = "lazyvim";
  version = "1.0";

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
    cp $init "$out/init.lua"
    cp -r ${lua} "$out/lua"
  '';

  meta = with lib; {
    description = "LazyVim";
    homepage = "https://github.com/LazyVim/LazyVim";
    platforms = platforms.all;
    license = licenses.mit;
  };
}
