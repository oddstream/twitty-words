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

  elseif phase == 'did' then
    destination = event.params.scene
    -- Code here runs when the scene is entirely on screen
    tim = timer.performWithDelay(1000, gotoDestination, 1)

    Util.loadMainDictionary()
    Util.loadHintDictionary()

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