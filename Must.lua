-- Must.lua

local Dim = require 'Dim'
local Grid = require 'Grid'

local composer = require('composer')
local scene = composer.newScene()
local widget = require('widget')

widget.setTheme('widget_theme_android_holo_dark')

local grid = nil

function scene:create(event)
  local sceneGroup = self.view

  _G.MUST_GROUPS.grid = display.newGroup()
  sceneGroup:insert(_G.MUST_GROUPS.grid)

  if system.getInfo('platform') == 'win32' then
    _G.DIMENSIONS = Dim.new(100)
  else
    _G.DIMENSIONS = Dim.new(200)
  end

  -- for debugging the gaps between cells problem
  -- display.setDefault('background', 0.5,0.5,0.5)

  grid = Grid.new(_G.DIMENSIONS.numX, _G.DIMENSIONS.numY)
  grid:newLevel()

end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen
  end
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene('Must')
  end
end

function scene:destroy(event)
  local sceneGroup = self.view

  grid:destroy()

  -- Code here runs prior to the removal of scene's view
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
