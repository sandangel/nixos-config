{ stdenvNoCC, zip, unzip, bash, fetchFromGitHub, lib, glib, gnome }:

stdenvNoCC.mkDerivation rec {
  pname = "gnome-shell-extension-flypie";
  version = "v18";
  src = fetchFromGitHub {
    owner = "Schneegans";
    repo = "Fly-Pie";
    rev = version;
    # sha256 = lib.fakeSha256;
    sha256 = "sha256-2dHdY/X4cm6zIys35Knc9g6+k15q9ykChqhAtvs9Aok=";
  };
  nativeBuildInputs = [ glib zip unzip ];
  buildPhase = ''
    runHook preBuild
    export NAME=flypie
    export DOMAIN=schneegans.github.com
    make SHELL=${bash}/bin/bash zip
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/gnome-shell/extensions/$NAME@$DOMAIN"
    unzip $NAME@$DOMAIN.zip -d "$out/share/gnome-shell/extensions/$NAME@$DOMAIN"
    runHook postInstall
  '';
  passthru = {
    extensionUuid = "flypie@schneegans.github.com";
    extensionPortalSlug = "flypie";
  };
  meta = with lib; {
    description = "A marking menu which can be used to launch applications, simulate hotkeys, open URLs and much more.";
    license = licenses.mit;
    homepage = "https://github.com/Schneegans/Fly-Pie";
    platforms = gnome.gnome-shell.meta.platforms;
  };
}
