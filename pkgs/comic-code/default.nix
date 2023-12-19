{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  name = "comic-code";
  version = "0.1.0";
  src = /home/nix-config/pkgs/comic-code/comic-code.tar.gz;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    mkdir -p $out/share/fonts/opentype
    install -m444 -Dt $out/share/fonts/truetype ./*.ttf
    install -m444 -Dt $out/share/fonts/opentype ./*.otf
  '';
  meta = { description = "A Comic Code Font Family derivation with Nerd font."; };
}
