local M = {}

-- returns a table of colors for givem or current theme
M.get = function()
  local colors = {
    white = '#abb2bf',
    darker_black = '#202023',
    black = '#2b2d3a', --  nvim bg
    black2 = '#333648',
    one_bg = '#282c34', -- real bg of onedark
    one_bg2 = '#353b45',
    one_bg3 = '#30343c',
    grey = '#7e8294',
    grey_fg = '#565c64',
    grey_fg2 = '#6f737b',
    light_grey = '#6f737b',
    red = '#ec7279',
    baby_pink = '#DE8C92',
    pink = '#ff75a0',
    line = '#7e8294',
    green = '#a0c980',
    vibrant_green = '#7eca9c',
    nord_blue = '#81A1C1',
    blue = '#6cb6eb',
    yellow = '#deb974',
    sun = '#EBCB8B',
    purple = '#d38aea',
    dark_purple = '#c678dd',
    teal = '#519ABA',
    orange = '#fca2aa',
    cyan = '#5dbbc1',
    statusline_bg = '#22262e',
    lightbg = '#2d3139',
    lightbg2 = '#262a32',
    pmenu_bg = '#A3BE8C',
    folder_bg = '#6cb6eb',
  }

  return colors
end

return M
