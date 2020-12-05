-- main.lua

local pprint = require 'pprint'
local composer = require 'composer'

-- local const = require 'constants'
local globalData = require 'globalData'

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

if system.getInfo('environment') == 'simulator' then
  composer.isDebug = true
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
  print('appName', system.getInfo('appName'))
  print('appVersionString', system.getInfo('appVersionString'))
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
const.FONTS.ROBOTO_MEDIUM = nil
_G.BOLDFONT = nil

local systemFonts = native.getFontNames()
for _, fontName in ipairs(systemFonts) do
  trace(fontName)
  if fontName == 'Roboto-Medium' then
    const.FONTS.ROBOTO_MEDIUM = native.newFont(fontName)
  elseif fontName == 'Roboto-Bold' then
    _G.BOLDFONT = native.newFont(fontName)
  end
end
if nil == const.FONTS.ROBOTO_MEDIUM then  const.FONTS.ROBOTO_MEDIUM = native.systemFont end
if nil == _G.BOLDFONT then  const.FONTS.ROBOTO_MEDIUM = native.systemFontBold end
]]

-- a global object containing useful precalculated dimensions
globalData.dim = {}

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

if not string.split then
  function _G.string:split( inSplitPattern )
    -- https://docs.coronalabs.com/tutorial/data/luaStringMagic/index.html

    local outResults = {}
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )

    while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end

    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
  end
end

globalData.dim = Dim.new(7,7)
-- grid (of slots) has no graphical elements, and does not change size, so persists across all games
globalData.grid = Grid.new(globalData.dim.numX, globalData.dim.numY)
globalData.mode = 'URGENT'  -- 'CASUAL' | 'URGENT' | 'ROBOTO' | <number>

-- for k,v in pairs( _G ) do
--   print( k , v )
-- end

composer.gotoScene('Splash', {params={scene='ModeMenu'}})
