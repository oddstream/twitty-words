-- Splash.lua

-- local json = require 'json'
local composer = require('composer')
local scene = composer.newScene()

local const = require 'constants'
local globalData = require 'globalData'

local Util = require 'Util'

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
  -- cleaned version (no 1- or 2- letter words) saves no memory (usage is 4628 KBytes)
  -- but must save some searching time as file size decreases from 4136 to 3773 KBytes
  -- awk '{if (length($0) > 3) print $0}'' words.alpha.txt > words_alpha_cleaned.txt'
  local file, msg = io.open(const.FILES.MAIN_DICTIONARY)
  if not file then
    trace('ERROR:', msg)
  else
    -- trace('opened', const.FILES.MAINDICTIONARY)
    globalData.DICTIONARY = file:read('*a')
    io.close(file)
    -- trace('main dictionary length', string.len(globalData.DICTIONARY))
  end

--[[
  -- building DICTIONARYIDX increases memory use from 4000 to 11000 KBytes

  for i=1, 26 do
    local letter = A2Z:sub(i,i)
    local first, last = string.find(globalData.DICTIONARY, '\n' .. letter)
    assert(first, letter) -- no words beginning with letter
    index[letter] = first
  end

  -- for key,value in pairs(index) do
  --   trace(key, value)
  -- end

  globalData.DICTIONARYIDX = {}
  for i=1, 25 do
    local letter = A2Z:sub(i,i)
    local nextLetter = A2Z:sub(i+1,i+1)
    globalData.DICTIONARYIDX[letter] = string.sub(globalData.DICTIONARY, index[letter], index[nextLetter])
  end
  globalData.DICTIONARYIDX['Z'] = string.sub(globalData.DICTIONARY, index['Z'])
]]

  -- https://raw.githubusercontent.com/sapbmw/The-Oxford-3000/master/The_Oxford_3000.txt
  -- filePath = system.pathForFile('assets/junk/Oxford3000.txt', system.ResourceDirectory)
  file, msg = io.open(const.FILES.USR_HINT_DICTIONARY)
  if not file then
    file, msg = io.open(const.FILES.SYS_HINT_DICTIONARY)
    if not file then
      trace('ERROR:', msg)
    end
  end
  if file then
    globalData.DICT = file:read('*a')
    io.close(file)
    -- trace('hint dict length', string.len(globalData.DICT))
  end

  -- double the speed of searching the hint dictionary by slicing it up into 26 sub dictionaries
  -- still need original (A-Z) dictionary for words that start with blank tile

  for i=1, 26 do
    local letter = A2Z:sub(i,i)
    local first, last = string.find(globalData.DICT, '\n' .. letter)
    assert(first, letter) -- no words beginning with letter
    index[letter] = first
  end

  -- for key,value in pairs(index) do
  --   trace(key, value)
  -- end

  globalData.DICTIDX = {}
  for i=1, 25 do
    local letter = A2Z:sub(i,i)
    local nextLetter = A2Z:sub(i+1,i+1)
    globalData.DICTIDX[letter] = string.sub(globalData.DICT, index[letter], index[nextLetter])
  end
  globalData.DICTIDX['Z'] = string.sub(globalData.DICT, index['Z'])

  -- trace('------')
  -- trace(globalData.DICTIDX['A'])
  -- trace('------')
  -- trace(globalData.DICTIDX['Z'])
  -- trace('------')

--[[
  -- cannot search a table for a wildcard, so cannot do this
  globalData.HINTWORDSTABLE = {}
  for line in io.lines(filePath) do
    if string.len(line) > 2 then
      table.insert(globalData.HINTWORDSTABLE, line)
    end
  end
]]
--[[
  filePath = system.pathForFile('ROBOTO_dict.json', system.DocumentsDirectory)
  file = io.open(filePath, 'r')
  if file then
    local contents = file:read('*a')
    io.close(file)
    globalData.ROBOTODICTIONARY = json.decode(contents)
  else
    globalData.ROBOTODICTIONARY = {'ANTEATERS','BADGERS','COWS','DORMICE','EARWIGS','FOXES','GERBILS','HAMSTERS'}
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

    Util.setBackground(sceneGroup)

    logo = display.newImage(sceneGroup, 'assets/splashlogo.png', system.ResourceDirectory, display.contentCenterX, display.contentCenterY)
    -- png is 420x420 pixels
    -- scale so it occupies one half of screen width
    local scale = display.actualContentWidth / 420 / 2
    logo:scale(scale,scale)
    assert(logo:addEventListener('tap', gotoDestination))

    -- https://docs.coronalabs.com/guide/graphics/3D.html
    transition.to( logo.path, { time=1000, --[[x1=80, y1=-80,]] x4=-420/2, y4=420/2 } )
    transition.fadeOut(logo, {time=1000})
    transition.scaleTo(logo, {time=1000, xScale=0.1, yScale=0.1})

    loadDictionaries()

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