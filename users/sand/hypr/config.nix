{ config, pkgs, default, lib, ... }:

let
  inherit (default) colors;

  pointer = config.home.pointerCursor;
  homeDir = config.home.homeDirectory;

  emoji = "${pkgs.wofi-emoji}/bin/wofi-emoji";
  launcher = "wofi";

  apply-hm-env = pkgs.writeShellScript "apply-hm-env" ''
    ${lib.optionalString (config.home.sessionPath != []) ''
      export PATH=${builtins.concatStringsSep ":" config.home.sessionPath}:$PATH
    ''}
    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''
        export ${k}=${toString v}
      '')
      config.home.sessionVariables)}
    ${config.home.sessionVariablesExtra}
    exec "$@"
  '';

  # runs processes as systemd transient services
  run-as-service = pkgs.writeShellScriptBin "run-as-service" ''
    exec ${pkgs.systemd}/bin/systemd-run \
      --slice=app-manual.slice \
      --property=ExitType=cgroup \
      --user \
      --wait \
      bash -lc "exec ${apply-hm-env} $@"
  '';
in
{
  home.packages = [ run-as-service ];
  wayland.windowManager.hyprland.extraConfig = ''
    $mod = SUPER

    monitor = auto, 4112x2572@60, auto, auto

    env = _JAVA_AWT_WM_NONREPARENTING,1
    env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

    # scale apps
    env = GDK_SCALE,2
    exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2

    # set cursor for HL itself
    exec-once = hyprctl setcursor ${pointer.name} ${toString pointer.size}

    exec-once = eww open bar
    exec-once = hyprpaper
    exec-once = run-as-service ${default.terminal.name}

    misc {
      # disable auto polling for config file changes
      disable_autoreload = true
      focus_on_activate = true
      # disable dragging animation
      animate_mouse_windowdragging = false
    }

    # touchpad gestures
    gestures {
      workspace_swipe = true
      workspace_swipe_forever = true
    }

    input {
      kb_layout = us

      # focus change on cursor move
      follow_mouse = 1
      sensitivity = 0.1
      natural_scroll = true
      repeat_rate = 3
      repeat_delay = 150

      touchpad {
        natural_scroll = true
        scroll_factor = 0.3
        drag_lock = true
      }
    }

    general {
      gaps_in = 5
      gaps_out = 5
      border_size = 2
      col.active_border = rgb(${colors.blue}) rgb(${colors.mauve}) 270deg
      col.inactive_border = rgb(${colors.crust}) rgb(${colors.lavender}) 270deg

      # group borders
      col.group_border_active = rgb(${colors.pink})
      col.group_border = rgb(${colors.surface0})
    }

    decoration {
      rounding = 16
      blur = true
      blur_size = 3
      blur_passes = 3
      blur_new_optimizations = true

      drop_shadow = true
      shadow_ignore_window = true
      shadow_offset = 0 5
      shadow_range = 50
      shadow_render_power = 3
      col.shadow = rgba(00000099)
    }

    animations {
      enabled = true
      animation = border, 1, 2, default
      animation = fade, 1, 4, default
      animation = windows, 1, 3, default, popin 80%
      animation = workspaces, 1, 2, default, slide
    }

    dwindle {
      # keep floating dimentions while tiling
      pseudotile = true
      preserve_split = true
    }

    # only allow shadows for floating windows
    windowrulev2 = noshadow, floating:0

    # make Firefox PiP window floating and sticky
    windowrulev2 = float, title:^(Picture-in-Picture)$
    windowrulev2 = pin, title:^(Picture-in-Picture)$

    # throw sharing indicators away
    windowrulev2 = workspace special silent, title:^(Firefox — Sharing Indicator)$
    windowrulev2 = workspace special silent, title:^(.*is sharing (your screen|a window)\.)$

    # idle inhibit while watching videos
    windowrulev2 = idleinhibit focus, class:^(mpv|.+exe)$
    windowrulev2 = idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$
    windowrulev2 = idleinhibit fullscreen, class:^(firefox)$

    windowrulev2 = dimaround, class:^(gcr-prompter)$

    # fix xwayland apps
    windowrulev2 = rounding 0, xwayland:1, floating:1

    layerrule = blur, ^(gtk-layer-shell)$
    layerrule = ignorezero, ^(gtk-layer-shell)$

    # mouse movements
    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow

    # compositor commands
    bind = $mod SHIFT, E, exec, pkill Hyprland
    bind = $mod, Q, killactive,
    bind = $mod, F, fullscreen,
    bind = $mod, G, togglegroup,
    bind = $mod SHIFT, N, changegroupactive, f
    bind = $mod SHIFT, P, changegroupactive, b
    bind = $mod, R, togglesplit,
    bind = $mod, T, togglefloating,
    bind = $mod, P, pseudo,
    bind = $mod ALT, , resizeactive,
    # toggle "monocle" (no_gaps_when_only)
    $kw = dwindle:no_gaps_when_only
    bind = $mod, M, exec, hyprctl keyword $kw $(($(hyprctl getoption $kw -j | jaq -r '.int') ^ 1))

    # utility
    # launcher
    bindr = $mod, W, exec, pkill .${launcher}-wrapped || run-as-service ${launcher}
    # terminal
    bind = $mod, Return, exec, run-as-service ${default.terminal.name}
    # emoji picker
    bind = $mod, E, exec, ${emoji}

    # move focus
    bind = $mod, left, movefocus, l
    bind = $mod, right, movefocus, r
    bind = $mod, up, movefocus, u
    bind = $mod, down, movefocus, d

    # window resize
    bind = $mod, S, submap, resize

    submap = resize
    binde = , right, resizeactive, 10 0
    binde = , left, resizeactive, -10 0
    binde = , up, resizeactive, 0 -10
    binde = , down, resizeactive, 0 10
    bind = , escape, submap, reset
    submap = reset

    # workspaces
    # binds mod + [shift +] {1..10} to [move to] ws {1..10}
    ${builtins.concatStringsSep "\n" (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in ''
          bind = $mod, ${ws}, workspace, ${toString (x + 1)}
          bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        ''
      )
      10)}

    # cycle workspaces
    bind = $mod, bracketleft, workspace, m-1
    bind = $mod, bracketright, workspace, m+1
  '';
}
