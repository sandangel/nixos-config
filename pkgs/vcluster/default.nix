{ lib, stdenvNoCC, stdenv, fetchurl, installShellFiles, }:
stdenvNoCC.mkDerivation rec {
  pname = "vcluster";
  version = "0.15.0";
  src = fetchurl {
    url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-${if stdenv.isAarch64 then "linux-arm64" else "linux-amd64"}";
    sha256 = if stdenv.isAarch64 then "sha256-FqhEZDXcoplX0B5MiG74cBD38rFMahFOeSUoqx1Fepw=" else lib.fakeSha256;
  };
  nativeBuildInputs = [ installShellFiles ];
  phases = [ "installPhase" "postInstall" ];
  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 $src -T $out/bin/vcluster
    runHook postInstall
  '';
  postInstall = ''
    installShellCompletion --cmd vcluster \
      --bash <($out/bin/vcluster completion bash) \
      --zsh <($out/bin/vcluster completion zsh)
  '';
  meta = with lib; {
    description = "Create fully functional virtual Kubernetes clusters";
    downloadPage = "https://github.com/loft-sh/vcluster";
    homepage = "https://www.vcluster.com/";
    license = licenses.asl20;
  };
}
