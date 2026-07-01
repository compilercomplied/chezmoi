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

-- Tell WezTerm to reload when current.txt changes
wezterm.add_to_config_reload_watch_list(
  os.getenv("HOME") .. "/.config/theme-repository/current.txt"
)

-- Load colors from active theme inside theme-repository
local function load_theme_colors()
  local home = os.getenv("HOME")
  local current_file = io.open(home .. "/.config/theme-repository/current.txt", "r")
  if not current_file then return nil end
  local theme_name = current_file:read("*l")
  current_file:close()
  if not theme_name then return nil end
  theme_name = theme_name:gsub("%s+", "") -- trim spaces
  
  local colors = {}
  local file = io.open(home .. "/.config/theme-repository/" .. theme_name .. ".txt", "r")
  if not file then return nil end
  for line in file:lines() do
    if not line:match("^%s*#") and not line:match("^%s*$") then
      local key, val = line:match("^%s*([%w_]+)%s*=%s*(#[%w]+)")
      if key and val then
        colors[key] = val
      end
    end
  end
  file:close()
  return colors
end

local colors = load_theme_colors()

if colors then
  config.colors = {
    foreground = colors.foreground,
    background = colors.background,
    cursor_fg = colors.background,
    cursor_bg = colors.orange,
    ansi = {
      colors.black,
      colors.red,
      colors.green,
      colors.yellow,
      colors.blue,
      colors.magenta,
      colors.cyan,
      colors.white
    },
    brights = {
      colors.grey or colors.black,
      colors.red,
      colors.green,
      colors.yellow,
      colors.blue,
      colors.magenta,
      colors.cyan,
      colors.white
    }
  }
end

return config
