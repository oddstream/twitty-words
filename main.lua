-- main.lua

local pprint = require 'pprint'
local composer = require 'composer'

local Dim = require 'Dim'
local Grid = require 'Grid'

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

if system.getInfo('platform') == 'win32' or system.getInfo('environment') == 'simulator' then
  print('_VERSION', _VERSION)
  print('screenOrigin', display.screenOriginX, display.screenOriginY)
  print('safeAreaInsets', display.getSafeAreaInsets())
  print('content', display.contentWidth, display.contentHeight)
  print('actualContent', display.actualContentWidth, display.actualContentHeight)
  print('safeActualContent', display.safeActualContentWidth, display.safeActualContentHeight)
  print('viewableContent', display.viewableContentWidth, display.viewableContentHeight)
  print('pixelWidth/Height', display.pixelWidth, display.pixelHeight)

  -- print('maxTextureSize', system.getInfo('maxTextureSize'))

  print('platformName', system.getInfo('platformName'))
  print('architectureInfo', system.getInfo('architectureInfo'))
  print('model', system.getInfo('model'))

  -- print('androidDisplayApproximateDpi', system.getInfo('androidDisplayApproximateDpi'))
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

native.setProperty('windowTitleText', 'Twitty') -- Win32

math.randomseed(os.time())

-- ugly globals

--[[
_G.ROBOTO_MEDIUM = nil
_G.BOLDFONT = nil

local systemFonts = native.getFontNames()
for _, fontName in ipairs(systemFonts) do
  trace(fontName)
  if fontName == 'Roboto-Medium' then
    _G.ROBOTO_MEDIUM = native.newFont(fontName)
  elseif fontName == 'Roboto-Bold' then
    _G.BOLDFONT = native.newFont(fontName)
  end
end
if nil == _G.ROBOTO_MEDIUM then  _G.ROBOTO_MEDIUM = native.systemFont end
if nil == _G.BOLDFONT then  _G.ROBOTO_MEDIUM = native.systemFontBold end
]]

-- a global object containing useful precalculated dimensions
_G.DIMENSIONS = {}

_G.ACME = 'assets/Acme-Regular.ttf'
_G.ROBOTO_MEDIUM = 'assets/Roboto-Medium.ttf'
_G.ROBOTO_BOLD = 'assets/Roboto-Bold.ttf'

-- https://en.wikipedia.org/wiki/Scrabble_letter_distributions
_G.SCRABBLE_LETTERS = '  AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ'
_G.SCRABBLE_SCORES = {
  [' '] = 0,
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

_G.TOUTES_DIRECTIONS = {'n','ne','e','se','s','sw','w','nw'}

local function RGB2DEC(r,g,b)
  local n = 1/255
  return {r*n, g*n, b*n}
end

_G.TWITTY_COLORS = {
  uiforeground = {1,1,1},
  uibackground = {0.1,0.1,0.1},
  uicontrol = RGB2DEC(255, 228, 181),  -- moccasin
  shadow = {0.1,0.1,0.1},
  -- uicontrol = {51*4/1020,181*4/1020,229*4/1020}, -- color from widget_theme_android_holo_dark@4x.png

  -- baize = {240*4/1020, 1, 240*4/1020},  -- Honeydew
  -- baize = {250*4/1020, 235*4/1020, 215*4/1020},  -- AntiqueWhite
  -- baize = {255*4/1020, 245*4/1020, 238*4/1020},  -- SeaShell
  -- baize = {248*4/1020, 248*4/1020, 255*4/1020},  -- GhostWhite

  baize = RGB2DEC(210, 180, 140), -- Tan
  -- selected = {1,0.8,0},
  -- back = {100*4/1020,147*4/1020,237*4/1020}, -- CornFlowerBlue
  -- tile = {1, 245*4/1020, 238*4/1020}, -- Seashell
  tile = {1, 1, 0.94}, -- ivory
  selected = RGB2DEC(255, 228, 181),  -- Moccasin
  marked = RGB2DEC(255, 228, 181), -- Moccasin
  tappy = RGB2DEC(255, 228, 181), -- Moccasin

  ivory = {1, 1, 0.94},
  gold = {1, 0.84, 0},
  moccasin = RGB2DEC(255, 228, 181),

  white = {1,1,1},
  offwhite = {0.91,0.9,0.9},
  aqua = {0,1,1},
  red = {1,0,0},
  orange = {1,0.65,0},
  pink = RGB2DEC(1,192,203),
  blue = {0,0,1},
  green = {0,1,0},
  purple = {0.5,0,0.5},
  gray = {0.5,0.5,0.5},
  black = {0,0,0},
}

_G.TWITTY_GROUPS = {
  grid = nil,
  ui = nil,
}

_G.TWITTY_SOUNDS = {
  complete = audio.loadSound('assets/complete.wav'),
  failure = audio.loadSound('assets/error_008.ogg'),

  select = {
    audio.loadSound('assets/click1.ogg'),
    audio.loadSound('assets/click2.ogg'),
    audio.loadSound('assets/click3.ogg'),
    audio.loadSound('assets/click4.ogg'),
    audio.loadSound('assets/click5.ogg'),
  },

  shuffle = audio.loadSound('assets/maximize_004.ogg'),
  swap = audio.loadSound('assets/minimize_007.ogg'),

  found = {
    audio.loadSound('assets/confirmation_001.ogg'),
    audio.loadSound('assets/confirmation_002.ogg'),
    audio.loadSound('assets/confirmation_003.ogg'),
    audio.loadSound('assets/confirmation_004.ogg'),
  },
  shake = audio.loadSound('assets/error_008.ogg'),

  timer = audio.loadSound('assets/question_004.ogg'),

  ui = {
    audio.loadSound('assets/back_001.ogg'),
    audio.loadSound('assets/back_002.ogg'),
    audio.loadSound('assets/back_003.ogg'),
    audio.loadSound('assets/back_004.ogg'),
  },
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

if not table.clone then
  function _G.table.clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in pairs(orig) do
        copy[orig_key] = orig_value
      end
    else -- number, string, boolean, etc
      copy = orig
    end
    return copy
  end
end

_G.DIMENSIONS = Dim.new()
-- grid (of slots) has no graphical elements, and does not change size, so persists across all games
_G.grid = Grid.new(_G.DIMENSIONS.numX, _G.DIMENSIONS.numY)
_G.GAME_MODE = 'timed'  -- 'untimed' | 'timed' | <number>

-- for k,v in pairs( _G ) do
--   print( k , v )
-- end

composer.gotoScene('Splash', {params={scene='ModeMenu'}})
