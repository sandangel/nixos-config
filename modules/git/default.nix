{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    extraConfig = {
      github.user = "sandangel";
      push.default = "tracking";
      pull.ff = "only";
      init.defaultBranch = "main";
      "url \"ssh://git@github.com/\"".insteadOf = "https://github.com/";
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
      commit.verbose = true;
      pager = {
        diff = "delta";
        log = "delta";
        reflog = "delta";
        show = "delta";
      };
    };
    userName = "San Nguyen";
    userEmail = "vinhsannguyen91@gmail.com";
    includes = [
      {
        condition = "gitdir:~/Work/Woven/**";
        contents = {
          user.email = "san.nguyen@woven-planet.global";
          "url \"ssh://git@github.tri-ad.tech/\"".insteadOf = "https://github.tri-ad.tech/";
        };
      }
    ];
    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "side-by-side decorations";
        whitespace-error-style = "22 reverse";
        navigate = true;
      };
    };
  };
}
