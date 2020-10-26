-- main.lua

local pprint = require 'pprint'
local composer = require 'composer'

-- build for Win32 to test the sound, because playing sounds in the simulator crashes the sound driver
_G.MUTE_AUDIO = system.getInfo('environment') == 'simulator'

function _G.trace(...)
  if system.getInfo('environment') == 'simulator' then
    local lst = {...}
    if #lst == 1 and type(lst[1]) == 'table' then
      pprint(lst[1])  -- doesn't take varargs
    else
      print(...)
    end
  end
end

if system.getInfo('environment') == 'simulator' then
  print(_VERSION)
  print('origin', display.screenOriginX, display.screenOriginY)
  print('content', display.contentWidth, display.contentHeight)
  print('pixels', display.pixelWidth, display.pixelHeight)
  print('actual content', display.contentWidth, display.contentHeight)
  print('viewable content', display.viewableContentWidth, display.viewableContentHeight)

  print('maxTextureSize', system.getInfo('maxTextureSize'))

  print('platformName', system.getInfo('platformName'))
  print('architectureInfo', system.getInfo('architectureInfo'))
  print('model', system.getInfo('model'))

  print('androidDisplayApproximateDpi', system.getInfo('androidDisplayApproximateDpi'))
end

--[[
_G.onTablet = system.getInfo('model') == 'iPad'
if not _G.onTablet then
  local approximateDpi = system.getInfo('androidDisplayApproximateDpi')
  if approximateDpi then
    local width = display.pixelWidth / approximateDpi
    local height = display.pixelHeight / approximateDpi
    if width > 4.5 and height > 7 then
      _G.onTablet = true
    end
  end
end
]]

native.setProperty('windowTitleText', 'Must') -- Win32

math.randomseed(os.time())

-- ugly globals

--[[
_G.FONT = nil
_G.BOLDFONT = nil

local systemFonts = native.getFontNames()
for _, fontName in ipairs(systemFonts) do
  trace(fontName)
  if fontName == 'Roboto-Medium' then
    _G.FONT = native.newFont(fontName)
  elseif fontName == 'Roboto-Bold' then
    _G.BOLDFONT = native.newFont(fontName)
  end
end
if nil == _G.FONT then  _G.FONT = native.systemFont end
if nil == _G.BOLDFONT then  _G.FONT = native.systemFontBold end
]]

-- a global object containing useful precalculated dimensions
_G.DIMENSIONS = {}

_G.TILE_FONT = 'assets/Acme-Regular.ttf'
-- _G.FONT = 'assets/Roboto-Medium.ttf'
-- _G.BOLD_FONT = 'assets/Roboto-Bold.ttf'

-- https://en.wikipedia.org/wiki/Scrabble_letter_distributions
_G.SCRABBLE_LETTERS = 'AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ'
_G.SCRABBLE_SCORES = {
  A = 1,
  B = 3,
  C = 3,
  D = 2,
  E = 1,
  F = 4,
  G = 2,
  H = 4,
  I = 1,
  J = 8,
  K = 5,
  L = 1,
  M = 3,
  N = 1,
  O = 1,
  P = 3,
  Q = 10,
  R = 1,
  S = 1,
  T = 1,
  U = 1,
  V = 4,
  W = 4,
  X = 8,
  Y = 4,
  Z = 10,
}

_G.FLIGHT_TIME = 2000

_G.MUST_COLORS = {
  uiforeground = {1,1,1},
  uibackground = {0.1,0.1,0.1},
  uicontrol = {51*4/1020,181*4/1020,229*4/1020}, -- color from widget_theme_android_holo_dark@4x.png

  -- baize = {240*4/1020, 1, 240*4/1020},  -- Honeydew
  -- baize = {250*4/1020, 235*4/1020, 215*4/1020},  -- AntiqueWhite
  -- baize = {255*4/1020, 245*4/1020, 238*4/1020},  -- SeaShell
  baize = {248*4/1020, 248*4/1020, 255*4/1020},  -- GhostWhite

  white = {1,1,1},
  offwhite = {0.91,0.9,0.9},
  -- selected = {1,0.8,0},
  -- back = {100*4/1020,147*4/1020,237*4/1020}, -- CornFlowerBlue
  border = {0.75,0.75,0.75},  -- Silver
  -- border = {0.5,0.5,0.5}, -- Gray

  ivory = {1, 1, 0.94}, -- normal tile background
  gold = {1, 0.84, 0},  -- selected tile background
  greenery = {0x88*4/1020, 0xB0*4/1020, 0x4b*4/1020},

  aqua = {0,1,1},
  red = {1,0,0},
  orange = {1,0.65,0},
  pink = {1,192*4/1020,203*4/1020},
  blue = {0,0,1},
  green = {0,1,0},
  purple = {0.5,0,0.5},
  gray = {0.5,0.5,0.5},
  black = {0,0,0},
}

_G.MUST_GROUPS = {
  grid = nil,
  ui = nil,
}

if not _G.table.contains then
  function _G.table.contains(tab, val)
    for index, value in ipairs(tab) do
      if value == val then
        return true, index
      end
    end
    return false, 0
  end
end
-- trace('table contains', type(_G.table.contains))

if not _G.table.length then
  function _G.table.length(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
  end
end
-- trace('table length', type(_G.table.length))

if not table.filter then
  -- for use on array-style tables
  function _G.table.filter(tbl, func)
    local out = {}
    for _,v in ipairs(tbl) do
      if func(v) then
        table.insert(out, v)
      end
    end
    return out
  end
end
-- trace('table filter', type(_G.table.filter))

_G.grid = nil

-- for k,v in pairs( _G ) do
--   print( k , v )
-- end

-- if system.getInfo('environment') == 'simulator' then
  -- composer.gotoScene('Must')
-- else
  composer.gotoScene('Splash', {params={scene='Must'}, effect='slideRight'})
-- end
