{
  fetchFromGitHub,
  wails3,
}:

wails3.overrideAttrs (
  _:
  let
    version = "3.0.0-beta.23";
    src = fetchFromGitHub {
      owner = "wailsapp";
      repo = "wails";
      rev = "v${version}";
      hash = "sha256-sAg0fzWIxpmPeJbGOSJMg4ZivZHTesGApNPu8BJAVxs=";
    };
  in
  {
    inherit version src;
    vendorHash = "sha256-+go9Z8pdqGAwo7aKDmiDuQCh1w+n+2JJCN3ScNdmoE8=";
  }
)
