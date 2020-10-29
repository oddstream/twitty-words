
-- ModeMenu.lua

local composer = require('composer')
local scene = composer.newScene()

local Tile = require 'Tile'

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

local function touchHandler(event)
  -- event.target is self.grp

  local grp = event.target

  local function _select()
    grp[2]:setFillColor(unpack(_G.MUST_COLORS.gold))
  end

  local function _deselect()
    grp[2]:setFillColor(unpack(_G.MUST_COLORS.ivory))
  end

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y, self.letter)
    -- deselect any selected tiles
    _select(event.x, event.y)

  elseif event.phase == 'moved' then
    -- trace('touch moved', event.x, event.y, self.letter)
    _select(event.x, event.y)

  elseif event.phase == 'ended' then
    -- trace('touch ended', event.x, event.y, self.letter)
    -- _deselect(event.x, event.y)

  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.y, self.letter)
    -- _deselect(event.x, event.y)
  end

  return true
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- TODO add a titlebar
-- TODO make tiles do something when touched

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
        grp:addEventListener('touch', touchHandler)
        grp:addEventListener('tap', function()
          grp[2]:setFillColor(unpack(_G.MUST_COLORS.gold))
          _G.GAME_MODE = mode
        composer.gotoScene('Must', {effect='slideLeft'})
      end)
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
