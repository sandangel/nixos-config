{ buildGoModule }:
buildGoModule rec {
  pname = "kubeswitch";
  version = "0.7.2";
  src = builtins.fetchGit {
    url = "https://github.com/danielfoehrKn/kubeswitch";
    ref = "refs/tags/${version}";
  };
  subPackages = [ "cmd" ];
  vendorSha256 = null;
  postInstall = ''
    mv $out/bin/cmd $out/bin/switcher
    cp -r $src/hack $out/
    cp -r $src/scripts $out/
  '';
}
