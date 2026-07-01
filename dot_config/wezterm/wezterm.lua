local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Hide the title bar while keeping the window resizable
config.window_decorations = "RESIZE"

-- Font configuration
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14.0
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Custom Color Schemes (Everforest Hard Contrast)
config.color_schemes = {
  ['Everforest Dark Hard'] = {
    foreground = "#d3c6aa",
    background = "#1e2326",
    cursor_fg = "#1e2326",
    cursor_bg = "#e69875",
    ansi = {
      "#7a8478", "#e67e80", "#a7c080", "#dbbc7f",
      "#7fbbb3", "#d699b6", "#83c092", "#f2efdf"
    },
    brights = {
      "#829181", "#e67e80", "#a7c080", "#dbbc7f",
      "#7fbbb3", "#d699b6", "#83c092", "#f2efdf"
    }
  },
  ['Everforest Light Hard'] = {
    foreground = "#5c6a72",
    background = "#f2efdf",
    cursor_fg = "#f2efdf",
    cursor_bg = "#f57d26",
    ansi = {
      "#a6b0a0", "#f85552", "#8da101", "#dfa000",
      "#3a94c5", "#df69ba", "#35a77c", "#5c6a72"
    },
    brights = {
      "#829181", "#f85552", "#8da101", "#dfa000",
      "#3a94c5", "#df69ba", "#35a77c", "#5c6a72"
    }
  }
}

-- Color scheme configuration with auto-switching
local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

local function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Everforest Dark Hard'
  else
    return 'Everforest Light Hard'
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())

return config
