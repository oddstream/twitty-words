-- Splash.lua

local composer = require('composer')
local scene = composer.newScene()

local tim = nil
local logo = nil
local destination = nil

local function gotoDestination(event)
  composer.gotoScene(destination)
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
    logo = display.newImage(sceneGroup, 'assets/splashlogo.png', system.ResourceDirectory, display.contentCenterX, display.contentCenterY)
    -- png is 420x420 pixels
    -- scale so it occupies one third of screen width
    local scale = display.contentWidth / 3 / 420
    logo:scale(scale, scale)
    assert(logo:addEventListener('tap', gotoDestination))

  elseif phase == 'did' then
    destination = event.params.scene
    -- Code here runs when the scene is entirely on screen
    tim = timer.performWithDelay(1500, gotoDestination, 1)
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