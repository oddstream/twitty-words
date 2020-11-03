
-- ModeMenu.lua

local composer = require('composer')
local scene = composer.newScene()

local Tappy = require 'Tappy'
local Util = require 'Util'

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- TODO add a titlebar

-- create()
function scene:create(event)

  local dim = _G.DIMENSIONS
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local function _createRow(y, title, mode)
    local x = dim.Q
    for i=1, string.len(title) do
      local tappy = Tappy.new(sceneGroup, x, y, function()
        _G.GAME_MODE = mode
        composer.gotoScene('Must', {effect='slideLeft'})
      end)
      tappy:setLabel(string.sub(title, i, i))
      x = x + dim.Q
    end
  end

  Util.setBackground(sceneGroup)

  local y
  y = (display.actualContentHeight / 2) - dim.Q - dim.Q
  _createRow(y, 'CASUAL', 'untimed')
  y = (display.actualContentHeight / 2)
  _createRow(y, 'URGENT', 'timed')
  y = (display.actualContentHeight / 2) + dim.Q + dim.Q
  _createRow(y, 'TWELVE', 12)

end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  composer.removeScene('FoundWords')
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
