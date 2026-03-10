-- wezterm.lua

local wezterm = require 'wezterm'
local config = {}

-- 사용 가능한 wezterm 객체 생성
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- 여기에 원하는 컬러 스킴 이름을 입력하세요.
config.color_scheme = 'Nord (Gogh)'

-- Split 간 이동: Command + 방향키
config.keys = {
  { key = 'LeftArrow', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection 'Down' },
}

return config
