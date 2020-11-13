-- Util.lua

local json = require 'json'

local Util = {}
Util.__index = Util

--[[
  Linear interpolation. The idea is very simple, you have 2 values, and you want to “walk” between those values by a factor.
  If you pass a factor of 0, you are pointing to the beginning of the walk so the value is equal to start.
  If you pass a factor of 1, you are pointing to the end of the walk so the value is equal to end.
  Any factor between 0 and 1 will add a (1-factor) of start argument and a factor of end argument.
  (e.g with start 0 and end 10 with a factor 0.5 you will have a 5, so the half of the path)
]]
function Util.lerp(start, finish, factor)
  -- return start*(1-factor) + finish*factor
  -- Precise method, which guarantees v = v1 when t = 1.
  -- https://en.wikipedia.org/wiki/Linear_interpolation
  return (1 - factor) * start + factor * finish;
end

--[[
  The opposite of lerp. Instead of a range and a factor, we give a range and a value to find out the factor.
]]
function Util.normalize(start, finish, value)
  return (value - start) / (finish - start)
end

--[[
  converts a value from the scale [fromMin, fromMax] to a value from the scale[toMin, toMax].
  It’s just the normalize and lerp functions working together.
]]
function Util.mapValue(value, fromMin, fromMax, toMin, toMax)
  return Util.lerp(toMin, toMax, Util.normalize(fromMin, fromMax, value))
end

function Util.clamp(value, min, max)
  return math.min(math.max(value, min), max)
end

function Util.setBackground(group)
  display.setDefault('background', unpack(_G.TWITTY_COLORS.baize))
  -- display.setDefault('textureWrapX', 'repeat')
  -- display.setDefault('textureWrapY', 'repeat')
  -- -- dependant on scale = 'letterbox' in config.lua
  -- local bg = display.newImage(group, 'assets/pexels-pixabay-301717.jpg') --, display.actualContentWidth, display.actualContentHeight)
  local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 3)
  -- bg.x = display.contentCenterX
  -- bg.y = display.contentCenterY
  -- bg.rotation = 90
  bg:setFillColor(unpack(_G.TWITTY_COLORS.baize))
  bg.alpha = 0.95
  -- bg.fill = {
  --   type = 'image',
  --   filename = 'assets/raccoon256.png'
  -- }
  -- bg.fill.scaleX = display.contentWidth / display.contentHeight / 2
  -- bg.fill.scaleY = display.contentWidth / display.contentHeight / 3
end

--[[
function Util.randomDirections()

  local degrees = math.random(1, 360)
  local radians = degrees * math.pi / 180

  local x = (display.actualContentWidth / 2) + (display.actualContentWidth) * math.sin(radians)
  local y = (display.actualContentHeight / 2) + (display.actualContentHeight) * math.cos(radians)

  local Q = _G.DIMENSIONS.Q

  local xMax = display.actualContentWidth + Q
  local xMin = -xMax
  local yMax = display.actualContentHeight + Q
  local yMin = -yMax

  x = Util.clamp(x, xMin, xMax)
  y = Util.clamp(y, yMin, yMax)

  -- x = math.random(-Q, display.actualContentWidth + Q)
  -- y = display.actualContentHeight + Q

  return x, y

end
]]

function Util.sound(name)
  -- build for Win32 to test the sound, because playing sounds in the simulator crashes the sound driver
  if system.getInfo('environment') == 'simulator' then
    -- trace('SOUND', name)
  else
    -- trace('SOUND', name, type(_G.TWITTY_SOUNDS[name]))
    local handle
    if type(_G.TWITTY_SOUNDS[name]) == 'table' then
      handle = _G.TWITTY_SOUNDS[name][math.random(1, #_G.TWITTY_SOUNDS[name])]
    elseif type(_G.TWITTY_SOUNDS[name]) == 'userdata' then
      handle = _G.TWITTY_SOUNDS[name]
    end
    if handle then
      audio.play(handle)
    end
  end
end

function Util.isWordInDictionary(word)

  if table.contains(_G.DICTIONARY_TRUE, word) then return true end
  if table.contains(_G.DICTIONARY_FALSE, word) then return false end

  local word2 = string.gsub(word, ' ', '%%u')
  local first,last = string.find(_G.DICTIONARY, '[^%u]' .. word2 .. '[^%u]')
  -- if first then
  --   trace('found', string.sub(_G.DICTIONARY, first+1, last-1))
  -- end
  if first then
    table.insert(_G.DICTIONARY_TRUE, word)
    -- trace(word, '> FOUND CACHE')
  else
    table.insert(_G.DICTIONARY_FALSE, word)
    -- trace(word, '> NOT FOUND CACHE')
  end

  return first ~= nil
  -- return true
end

function Util.isWordInDict(word)

  if table.contains(_G.DICT_TRUE, word) then return true end
  if table.contains(_G.DICT_FALSE, word) then return false end

  local word2 = string.gsub(word, ' ', '%%u')
  local first,last = string.find(_G.DICT, '[^%u]' .. word2 .. '[^%u]')
  -- if first then
  --   trace('found', string.sub(_G.DICT, first+1, last-1))
  -- end
  if first then
    table.insert(_G.DICT_TRUE, word)
    -- trace(word, '> FOUND 3000 CACHE')
  else
    table.insert(_G.DICT_FALSE, word)
    -- trace(word, '> NOT FOUND 3000 CACHE')
  end

  return first ~= nil
  -- return true
end

function Util.isWordPrefixInDictionary(word)

  if table.contains(_G.DICTIONARY_TRUE, word) then return true end
  if table.contains(_G.DICTIONARY_PREFIX_TRUE, word) then return true end
  if table.contains(_G.DICTIONARY_PREFIX_FALSE, word) then return false end

  local word2 = string.gsub(word, ' ', '%%u')
  local first,last = string.find(_G.DICTIONARY, '[^%u]' .. word2)
  -- if first then
  --   trace('found', string.sub(_G.DICT, first+1, last-1))
  -- end

  if first then
    table.insert(_G.DICTIONARY_PREFIX_TRUE, word)
    -- trace(word, '> FOUND 3000 PREFIX CACHE')
  else
    table.insert(_G.DICTIONARY_PREFIX_FALSE, word)
    -- trace(word, '> NOT FOUND 3000 PREFIX CACHE')
  end

  return first ~= nil
  -- return true
end

function Util.isWordPrefixInDict(word)

  if table.contains(_G.DICT_TRUE, word) then return true end
  if table.contains(_G.DICT_PREFIX_TRUE, word) then return true end
  if table.contains(_G.DICT_PREFIX_FALSE, word) then return false end

  local word2 = string.gsub(word, ' ', '%%u')
  local first,last = string.find(_G.DICT, '[^%u]' .. word2)
  -- if first then
  --   trace('found', string.sub(_G.DICT, first+1, last-1))
  -- end

  if first then
    table.insert(_G.DICT_PREFIX_TRUE, word)
    -- trace(word, '> FOUND 3000 PREFIX CACHE')
  else
    table.insert(_G.DICT_PREFIX_FALSE, word)
    -- trace(word, '> NOT FOUND 3000 PREFIX CACHE')
  end

  return first ~= nil
  -- return true
end


function Util.cloneTable(t)
  return json.decode( json.encode( t ) )
end

return Util
