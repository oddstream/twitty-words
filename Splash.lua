-- Splash.lua

local composer = require('composer')
local scene = composer.newScene()

local Util = require 'Util'

local tim = nil
local logo = nil
local destination = nil

local function loadDictionary()
  -- look for dictionary file in resource directory (the one containing main.lua)
  local filePath = system.pathForFile('Collins Scrabble Words (2019).txt', system.ResourceDirectory)
  local file = io.open(filePath)
  if not file then
    trace('ERROR: Cannot open', filePath)
  else
    trace('opened', filePath)
    _G.DICTIONARY = file:read('*a')
    io.close(file)
    trace('dictionary length', string.len(_G.DICTIONARY))
  end
end

local function gotoDestination(event)
  composer.gotoScene(destination, {effect='slideLeft'})
  return true -- we handled tap event
end

function scene:create(event)
  local sceneGroup = self.view
  -- display.setDefault('background', unpack(_G.MUST_COLORS.baize))
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

    loadDictionary()

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
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene('Splash')
  end
end

function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  if tim then
    timer.cancel(tim)
    tim = nil
  end
  logo:removeEventListener('tap', gotoDestination)
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