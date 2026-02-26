local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_size = 14.0

if wezterm.target_triple:find("darwin") then
    config.window_background_opacity = 0.85
    config.macos_window_background_blur = 20
end

return config
