-- Util.lua

local widget = require 'widget'

local const = require 'constants'
local globalData = require 'globalData'

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

  display.setDefault('background', unpack(const.COLORS.baize))
  -- tried a bitmap (wood effect) background
  -- it didn't scale well
  -- couldn't get textureWrapX/Y to work

  -- make background wide/high enough that scrolling it doesn't show edges
  local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth * 3, display.contentHeight * 3)
  bg:setFillColor(unpack(const.COLORS.baize))
  bg.alpha = 0.95

end

--[[
function Util.randomDirections()

  local degrees = math.random(1, 360)
  local radians = degrees * math.pi / 180

  local x = (display.actualContentWidth / 2) + (display.actualContentWidth) * math.sin(radians)
  local y = (display.actualContentHeight / 2) + (display.actualContentHeight) * math.cos(radians)

  local Q = globalData.dim.Q

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
  if system.getInfo('environment') ~= 'simulator' then
    -- trace('SOUND', name, type(const.SOUNDS[name]))
    local handle
    if type(const.SOUNDS[name]) == 'table' then
      handle = const.SOUNDS[name][math.random(1, #const.SOUNDS[name])]
    elseif type(const.SOUNDS[name]) == 'userdata' then
      handle = const.SOUNDS[name]
    end
    if handle then
      audio.play(handle)
    end
  end
end

function Util.isWordInDictionary(word)
  -- no point using a cache if only used to check words user has selected
--[[
  if table.contains(globalData.DICTIONARY_TRUE, word) then return true end
  if table.contains(globalData.DICTIONARY_FALSE, word) then return false end
]]
  local word2 = string.gsub(word, ' ', '%%u')
  local first,last = string.find(globalData.DICTIONARY, '[^%u]' .. word2 .. '[^%u]')
  -- if first then
  --   trace('found', string.sub(globalData.DICTIONARY, first+1, last-1))
  -- end
--[[
  if first then
    table.insert(globalData.DICTIONARY_TRUE, word)
    -- trace(word, '> FOUND CACHE')
  else
    table.insert(globalData.DICTIONARY_FALSE, word)
    -- trace(word, '> NOT FOUND CACHE')
  end
]]
  return first ~= nil
  -- return true
end

function Util.isWordInDict(word)

  if table.contains(globalData.DICT_TRUE, word) then return true end
  -- if globalData.DICT_TRUE[word] then return true end

  -- if table.contains(globalData.ROBOTODICTIONARY, word) then return true end

  if table.contains(globalData.DICT_FALSE, word) then return false end
  -- if globalData.DICT_FALSE[word] then return false end

  local word2 = string.gsub(word, ' ', '%%u')

  local first, last
  local initialLetter = string.sub(word,1,1)
  if initialLetter == ' ' then
    first,last = string.find(globalData.DICT, '[^%u]' .. word2 .. '[^%u]')
  else
    assert(globalData.DICTIDX[initialLetter], '<' .. initialLetter .. '>')
    first,last = string.find(globalData.DICTIDX[initialLetter], '[^%u]' .. word2 .. '[^%u]')
  end

  -- if first then
  --   trace('found', string.sub(globalData.DICT, first+1, last-1))
  -- end
  if first then
    table.insert(globalData.DICT_TRUE, word)
    -- globalData.DICT_TRUE[word] = true
    -- trace(word, '> FOUND IN CACHE')
  else
    -- globalData.DICT_FALSE[word] = true
    table.insert(globalData.DICT_FALSE, word)
    -- trace(word, '> NOT FOUND IN CACHE')
  end

  return first ~= nil
  -- return true

end

--[[
function Util.isWordPrefixInDictionary(word)

  -- if table.contains(globalDaglobalData.DICTIONARY_TRUE, word) then return true end
  -- if table.contains(globalDaglobalData.DICTIONARY_PREFIX_TRUE, word) then return true end
  -- if table.contains(globalDaglobalData.DICTIONARY_PREFIX_FALSE, word) then return false end

  local word2 = string.gsub(word, ' ', '%%u')
  local first,last = string.find(globalDaglobalData.DICTIONARY, '[^%u]' .. word2)
  -- if first then
  --   trace('found', string.sub(globalDaglobalData.DICT, first+1, last-1))
  -- end

  if first then
    table.insert(globalDaglobalData.DICTIONARY_PREFIX_TRUE, word)
    -- trace(word, '> FOUND IN PREFIX DICTIONARY')
  else
    table.insert(globalDaglobalData.DICTIONARY_PREFIX_FALSE, word)
    -- trace(word, '> NOT FOUND IN PREFIX DICTIONARY')
  end

  if first then
    trace('PREFIX FOUND', word2)
  else
    trace('PREFIX NOT FOUND', word2)
  end

  return first ~= nil
  -- return true
end
]]

function Util.isWordPrefixInDict(word)

  if table.contains(globalData.DICT_TRUE, word) then return true end
  -- if globalData.DICT_TRUE[word] then return true end

  -- if table.contains(globalData.ROBOTODICTIONARY, word) then return true end

  if table.contains(globalData.DICT_PREFIX_TRUE, word) then return true end
  -- if globalData.DICT_PREFIX_TRUE[word] then return true end

  if table.contains(globalData.DICT_PREFIX_FALSE, word) then return false end
  -- if globalData.DICT_PREFIX_FALSE[word] then return false end

  local initialLetter = string.sub(word,1,1)
  local word2 = string.gsub(word, ' ', '%%u')
  local first,last
  if initialLetter == ' ' then
    first, last = string.find(globalData.DICT, '[^%u]' .. word2)
  else
    first, last = string.find(globalData.DICTIDX[initialLetter], '[^%u]' .. word2)
  end

  -- if first then
  --   trace('found', string.sub(globalData.DICT, first+1, last-1))
  -- end

  if first then
    table.insert(globalData.DICT_PREFIX_TRUE, word)
    -- globalData.DICT_PREFIX_TRUE[word] = true
    -- trace(word, '> FOUND IN PREFIX CACHE')
  else
    table.insert(globalData.DICT_PREFIX_FALSE, word)
    -- globalData.DICT_PREFIX_FALSE[word] = true
    -- trace(word, '> NOT FOUND IN PREFIX CACHE')
  end

  return first ~= nil
  -- return true
end

function Util.resetDictionaries()
  globalData.DICT_TRUE = {}
  globalData.DICT_FALSE = {}
  globalData.DICT_PREFIX_TRUE = {}
  globalData.DICT_PREFIX_FALSE = {}
end

function Util.checkDictionaries()
  -- check all words in hint dictionary are in main dictionary
  local filePath = system.pathForFile('1000 words.txt', system.ResourceDirectory)
  print('checking', filePath)
  local count = 0
  local timeStart = system.getTimer()
  for line in io.lines(filePath) do
    count = count + 1
    if not Util.isWordInDictionary(line) then
      print(string.format('WARNING: \"%s\" not in main dictionary', line))
    end
  end
  local timeStop = system.getTimer()

  print('finished, checking', count, 'words in', math.floor((timeStop - timeStart) / 1000), 'seconds')
  -- checked 1324 words in 206 seconds (0.155 seconds/word to check main dictionary)
end

-- don't use this on a table that contains tables
-- function Util.cloneTable(t)
--   return json.decode( json.encode( t ) )
-- end

function Util.showAlert(title, message, buttonLabels, listener)

  local dim = globalData.dim

  buttonLabels = buttonLabels or {'OK'}

  local grp = display.newGroup()
  globalData.gridGroup:insert(grp)
  grp.x, grp.y = display.contentCenterX, display.contentCenterY

  -- rip from function Tile.createGraphics()

  local radius = dim.Q / 15
  local width = display.contentWidth * 0.666
  local height = width / 2 --1.61803398875
  local titleFontSize = dim.tileFontSize * 0.5
  local messageFontSize = dim.tileFontSize * 0.3
  local buttonFontSize = dim.tileFontSize * 0.5
  local buttonWidth = buttonFontSize * 3

  -- grp[1]
  local rectShadow = display.newRoundedRect(grp, dim.offset3D, dim.offset3D, width, height, radius)
  rectShadow:setFillColor(unpack(const.COLORS.shadow))

  -- grp[2]
  local rectBack = display.newRoundedRect(grp, 0, 0, width, height, radius)
  rectBack:setFillColor(unpack(const.COLORS.selected))

  -- grp[3]
  local textTitle = display.newText(grp, title, 0, -(height/2) + titleFontSize, const.FONTS.ACME, titleFontSize)
  textTitle:setFillColor(0,0,0)

  -- grp[4]
  local textMessage = display.newText(grp, message, 0, 0, const.FONTS.ROBOTO_MEDIUM, messageFontSize)
  textMessage:setFillColor(0,0,0)

  local buttonGroup = display.newGroup()
  grp:insert(buttonGroup)

  local x = -(#buttonLabels * buttonWidth)
  x = x / 2
  x = x + buttonWidth / 2

  for i,buttonLabel in pairs(buttonLabels) do
    -- local rect = display.newRect(grp, x, height/2, buttonWidth, buttonFontSize)
    -- rect:setFillColor(math.random(),math.random(),math.random())
    -- rect.anchorY = 1

    local button = widget.newButton({
      x = x,
      y = height/2 - (buttonFontSize/2),
      onRelease = function()
        globalData.grid:resumeTouch()
        globalData.toolbar:resumeTouch()
        -- display.getCurrentStage():setFocus(nil)
        if listener then
          if type(listener) == 'function' then listener({action='clicked', index=i})
          elseif type(listener) == 'table' then trace('ERROR: table listener not supported')
          else trace('ERROR: listener type not supported', type(listener)) end
        end
        grp:removeSelf()
      end,
      label = buttonLabel,
      labelColor = { default=const.COLORS.black, over=const.COLORS.shadow },
      labelAlign = 'center',
      font = const.FONTS.ACME,
      fontSize = buttonFontSize,
      textOnly = true,
    })
    grp:insert(button)
    button.anchorY = 1

    x = x + buttonWidth
  end

  -- https://docs.coronalabs.com/api/type/EventDispatcher/dispatchEvent.html

  globalData.grid:suspendTouch()
  globalData.toolbar:suspendTouch()
  -- display.getCurrentStage():setFocus(grp)

  return grp

end

return Util
