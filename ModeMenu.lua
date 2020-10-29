
-- ModeMenu.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local scene = composer.newScene()

local Tile = require 'Tile'

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

  local dim = _G.DIMENSIONS
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local function _createTile(x, y, txt)
    local grp = Tile.createGraphics(x, y, txt)
    sceneGroup:insert(grp)
    -- grp:scale(0.5, 0.5)
    return grp
  end

  local function _createRow(y, title, mode)
    local x = dim.Q
    for i=1, string.len(title) do
      local grp = _createTile(x, y, string.sub(title, i, i))
      grp:addEventListener('tap', function() composer.gotoScene('Must', {effect='slideLeft', params={mode=mode}}) end)
      x = x + dim.Q
    end
  end

  display.setDefault('background', unpack(_G.MUST_COLORS.baize))

  local y
  y = (display.contentHeight / 2) - dim.Q - dim.Q
  _createRow(y, 'NORMAL', 'untimed')
  y = (display.contentHeight / 2)
  _createRow(y, 'TIMED', 'timed')
  y = (display.contentHeight / 2) + dim.Q + dim.Q
  _createRow(y, 'TEN', 10)
  y = (display.contentHeight / 2) + dim.Q + dim.Q + dim.Q + dim.Q
  _createRow(y, 'TWENTY', 20)

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
    -- TODO put flyAwayTiles() here?
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    -- composer.removeScene('FoundWords')
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  assert(Runtime:removeEventListener('key', scene))
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
