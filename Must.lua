-- Must.lua

local Grid = require 'Grid'
local Toolbar = require 'Toolbar'
local Util = require 'Util'

local composer = require('composer')
local scene = composer.newScene()
local widget = require('widget')

widget.setTheme('widget_theme_android_holo_dark')

function scene:create(event)
  local sceneGroup = self.view

  -- display.setDefault('background', unpack(_G.MUST_COLORS.baize))

  _G.MUST_GROUPS.grid = self.view -- TODO referenced by Tile

  Util.setBackground(self.view)

  -- create a separate group for UI objects, so they are always on top of grid
  _G.MUST_GROUPS.ui = display.newGroup()
  sceneGroup:insert(_G.MUST_GROUPS.ui)

end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    _G.toolBar = Toolbar.new()

    _G.grid = Grid.new(_G.DIMENSIONS.numX, _G.DIMENSIONS.numY)
    _G.grid:newGame()

  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen
    Runtime:addEventListener('key', scene)
    Runtime:addEventListener('system', scene)
  end
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    if not Runtime:removeEventListener('key', scene) then
      trace('could not removeEventListener key in scene:hide')
    end
    if not Runtime:removeEventListener('system', scene) then
      trace('could not removeEventListener system in scene:hide')
    end
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene('Must')
  end
end

function scene:destroy(event)
  local sceneGroup = self.view

  _G.grid:destroy()

  -- Code here runs prior to the removal of scene's view
end

function scene:key(event)
  local phase = event.phase

  if phase == 'up' then
    if event.keyName == 'j' then
      _G.grid:jumble()
    elseif event.keyName == 'r' then
      _G.grid:addRowAtTop()
    elseif event.keyName == 'w' then
      composer.showOverlay('FoundWords', {effect='slideRight'})
    end
  end
end

function scene:system(event)
  -- print( "System event name and type: " .. event.name, event.type )
  -- if event.type == 'applicationExit' then
  -- elseif event.type == 'applicationSuspend' then
  -- elseif event.type == 'applicationResume' then
  -- end
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
