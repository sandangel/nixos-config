{ pkgs, ... }:
{
  home.packages = with pkgs; [ wofi ];

  xdg.configFile = {
    "wofi/config".text = ''
      width=420
      height=550
      location=center
      show=drun
      matching=fuzzy
      filter_rate=100
      allow_markup=true
      no_actions=true
      halign=fill
      orientation=vertical
      content_halign=fill
      insensitive=true
      allow_images=true
      image_size=28
      gtk_dark=true
      term=ghostty
    '';

    "wofi/style.css".text = builtins.readFile ./style.css;
  };
}
