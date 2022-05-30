local wezterm = require 'wezterm'
local os = require 'os'
local CTRL = '\x17'

local move_around = function(window, pane, direction_wez, direction_nvim)
  local cmd = '/nix-config/users/sand/wezterm/wezterm.nvim /tmp/nvim_wezterm_pane_'
      .. pane:pane_id() .. ' ' .. direction_nvim
  local result = os.execute(cmd)
  if result then
    window:perform_action(wezterm.action { SendString = CTRL .. direction_nvim }, pane)
  else
    window:perform_action(wezterm.action { ActivatePaneDirection = direction_wez }, pane)
  end
end

wezterm.on('move-left', function(window, pane)
  move_around(window, pane, 'Left', 'h')
end)

wezterm.on('move-right', function(window, pane)
  move_around(window, pane, 'Right', 'l')
end)

wezterm.on('move-up', function(window, pane)
  move_around(window, pane, 'Up', 'k')
end)

wezterm.on('move-down', function(window, pane)
  move_around(window, pane, 'Down', 'j')
end)

return {
  window_decorations = 'NONE',
  font = wezterm.font 'ComicCodeLigatures Nerd Font Mono',
  color_scheme = 'Snazzy',
  line_height = 1.2,
  font_size = 10.0,
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false,
  use_ime = false,
  use_dead_keys = false,
  scrollback_lines = 100000,
  debug_key_events = false,
  enable_wayland = true,
  key_map_preference = 'Physical',
  dpi = 192.0,
  exit_behavior = 'Close',
  send_composed_key_when_right_alt_is_pressed = false,
  disable_default_key_bindings = true,
  disable_default_mouse_bindings = true,
  window_padding = {
    left = '0.5cell',
    right = '0.5cell',
    top = 0,
    bottom = 0,
  },
  keys = {
    { key = 'c', mods = 'CMD', action = wezterm.action { CopyTo = 'Clipboard' } },
    { key = 'v', mods = 'CMD', action = wezterm.action { PasteFrom = 'Clipboard' } },
    { key = '-', mods = 'ALT', action = wezterm.action { SplitVertical = { domain = 'CurrentPaneDomain' } } },
    { key = '=', mods = 'ALT', action = wezterm.action { SplitHorizontal = { domain = 'CurrentPaneDomain' } } },
    { key = 'w', mods = 'ALT', action = wezterm.action { SpawnTab = 'DefaultDomain' } },
    { key = 'z', mods = 'ALT', action = 'TogglePaneZoomState' },
    { key = 'Enter', mods = 'ALT', action = 'ToggleFullScreen' },
    { key = '-', mods = 'CTRL|SHIFT', action = 'DecreaseFontSize' },
    { key = '=', mods = 'CTRL|SHIFT', action = 'IncreaseFontSize' },
    { key = '0', mods = 'CTRL|SHIFT', action = 'ResetFontSize' },

    { key = '1', mods = 'ALT', action = wezterm.action { ActivateTab = 0 } },
    { key = '2', mods = 'ALT', action = wezterm.action { ActivateTab = 1 } },
    { key = '3', mods = 'ALT', action = wezterm.action { ActivateTab = 2 } },
    { key = '4', mods = 'ALT', action = wezterm.action { ActivateTab = 3 } },
    { key = '5', mods = 'ALT', action = wezterm.action { ActivateTab = 4 } },
    { key = '6', mods = 'ALT', action = wezterm.action { ActivateTab = 5 } },
    { key = '7', mods = 'ALT', action = wezterm.action { ActivateTab = 6 } },
    { key = '8', mods = 'ALT', action = wezterm.action { ActivateTab = 7 } },
    { key = '9', mods = 'ALT', action = wezterm.action { ActivateTab = 8 } },
    { key = '0', mods = 'ALT', action = wezterm.action { ActivateTab = 9 } },

    { key = 'q', mods = 'ALT', action = wezterm.action { CloseCurrentTab = { confirm = true } } },
    { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action { Search = { CaseInSensitiveString = '' } } },
    { key = 'l', mods = 'CTRL|SHIFT', action = 'ShowDebugOverlay' },
    { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action { ClearScrollback = 'ScrollbackAndViewport' } },

    { key = 'h', mods = 'CTRL', action = wezterm.action({ EmitEvent = 'move-left' }) },
    { key = 'l', mods = 'CTRL', action = wezterm.action({ EmitEvent = 'move-right' }) },
    { key = 'k', mods = 'CTRL', action = wezterm.action({ EmitEvent = 'move-up' }) },
    { key = 'j', mods = 'CTRL', action = wezterm.action({ EmitEvent = 'move-down' }) },
  },
  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { CompleteSelection = 'Clipboard' },
    },
    {
      event = { Up = { streak = 2, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { CompleteSelection = 'Clipboard' },
    },
    {
      event = { Up = { streak = 3, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { CompleteSelection = 'Clipboard' },
    },
    {
      event = { Down = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { SelectTextAtMouseCursor = 'Cell' },
    },
    {
      event = { Down = { streak = 2, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { SelectTextAtMouseCursor = 'Word' },
    },
    {
      event = { Down = { streak = 3, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { SelectTextAtMouseCursor = 'Line' },
    },
    {
      event = { Drag = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { ExtendSelectionToMouseCursor = 'Cell' },
    },
    {
      event = { Drag = { streak = 2, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { ExtendSelectionToMouseCursor = 'Word' },
    },
    {
      event = { Drag = { streak = 3, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action { ExtendSelectionToMouseCursor = 'Line' },
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = 'OpenLinkAtMouseCursor',
    },
    {
      event = { Down = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = 'Nop',
    },
  },
  colors = {
    tab_bar = {
      background = '#22262e',
      active_tab = {
        bg_color = '#81a1c1',
        fg_color = '#22262e',
        intensity = 'Normal',
        underline = 'None',
        italic = false,
        strikethrough = false,
      },
      inactive_tab = {
        bg_color = '#22262e',
        fg_color = '#abb2bf',
      },
      inactive_tab_hover = {
        bg_color = '#81a1c1',
        fg_color = '#22262e',
        italic = true,
      },
      new_tab = {
        bg_color = '#22262e',
        fg_color = '#abb2bf',
      },
      new_tab_hover = {
        bg_color = '#81a1c1',
        fg_color = '#22262e',
        italic = true,
      }
    }
  }
}
