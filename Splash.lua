-- Splash.lua

local composer = require('composer')
local scene = composer.newScene()

local tim = nil
local logo = nil
local destination = nil

local function loadDictionaries()
  -- look for dictionary file in resource directory (the one containing main.lua)

  local A2Z = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  local index = {}

  -- https://boardgames.stackexchange.com/questions/38366/latest-collins-scrabble-words-list-in-text-file
  -- local filePath = system.pathForFile('Collins Scrabble Words (2019).txt', system.ResourceDirectory)

  -- https://github.com/dwyl/english-words
  local filePath = system.pathForFile('words_alpha.txt', system.ResourceDirectory)
  local file, msg = io.open(filePath)
  if not file then
    trace('ERROR: Cannot open', filePath, msg)
  else
    trace('opened', filePath)
    _G.DICTIONARY = file:read('*a')
    io.close(file)
    trace('dictionary length', string.len(_G.DICTIONARY))
  end

--[[
  -- building DICTIONARYIDX increases memory use from 4000 to 11000 KBytes

  for i=1, 26 do
    local letter = A2Z:sub(i,i)
    local first, last = string.find(_G.DICTIONARY, '\n' .. letter)
    assert(first, letter) -- no words beginning with letter
    index[letter] = first
  end

  -- for key,value in pairs(index) do
  --   trace(key, value)
  -- end

  _G.DICTIONARYIDX = {}
  for i=1, 25 do
    local letter = A2Z:sub(i,i)
    local nextLetter = A2Z:sub(i+1,i+1)
    _G.DICTIONARYIDX[letter] = string.sub(_G.DICTIONARY, index[letter], index[nextLetter])
  end
  _G.DICTIONARYIDX['Z'] = string.sub(_G.DICTIONARY, index['Z'])
]]

  -- https://raw.githubusercontent.com/sapbmw/The-Oxford-3000/master/The_Oxford_3000.txt
  -- filePath = system.pathForFile('assets/junk/Oxford3000.txt', system.ResourceDirectory)
  filePath = system.pathForFile('1000 words.txt', system.ResourceDirectory)
  file, msg = io.open(filePath)
  if not file then
    trace('ERROR: Cannot open', filePath, msg)
  else
    trace('opened', filePath)
    _G.DICT = file:read('*a')
    io.close(file)
    trace('dict length', string.len(_G.DICT))
  end

  -- double the speed of searching the hint dictionary by slicing it up into 26 sub dictionaries
  -- still need original (A-Z) dictionary for words that start with blank tile

  for i=1, 26 do
    local letter = A2Z:sub(i,i)
    local first, last = string.find(_G.DICT, '\n' .. letter)
    assert(first, letter) -- no words beginning with letter
    index[letter] = first
  end

  -- for key,value in pairs(index) do
  --   trace(key, value)
  -- end

  _G.DICTIDX = {}
  for i=1, 25 do
    local letter = A2Z:sub(i,i)
    local nextLetter = A2Z:sub(i+1,i+1)
    _G.DICTIDX[letter] = string.sub(_G.DICT, index[letter], index[nextLetter])
  end
  _G.DICTIDX['Z'] = string.sub(_G.DICT, index['Z'])

  -- trace('------')
  -- trace(_G.DICTIDX['A'])
  -- trace('------')
  -- trace(_G.DICTIDX['Z'])
  -- trace('------')

--[[
  -- cannot search a table for a wildcard, so cannot do this
  _G.HINTWORDSTABLE = {}
  for line in io.lines(filePath) do
    if string.len(line) > 2 then
      table.insert(_G.HINTWORDSTABLE, line)
    end
  end
]]

end

local function gotoDestination(event)
  composer.gotoScene(destination, {effect='slideLeft'})
  return true -- we handled tap event
end

function scene:create(event)
  local sceneGroup = self.view
end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)

    -- Util.setBackground(sceneGroup)

    logo = display.newImage(sceneGroup, 'assets/splashlogo.png', system.ResourceDirectory, display.contentCenterX, display.contentCenterY)
    -- png is 420x420 pixels
    -- scale so it occupies one half of screen width
    local scale = display.actualContentWidth / 420 / 2
    logo:scale(scale,scale)
    assert(logo:addEventListener('tap', gotoDestination))

    loadDictionaries()

    -- transition.fadeOut(logo, {time=1000})

  elseif phase == 'did' then
    destination = event.params.scene
    -- Code here runs when the scene is entirely on screen
    tim = timer.performWithDelay(1000, gotoDestination, 1)
  end
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    logo:removeEventListener('tap', gotoDestination)
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
  end
end

function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  if tim then
    timer.cancel(tim)
    tim = nil
  end
  composer.removeScene('Splash')
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)
-- -----------------------------------------------------------------------------------

return scene