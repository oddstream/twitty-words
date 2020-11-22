
-- ModeMenu.lua

local composer = require('composer')
local scene = composer.newScene()

local Tappy = require 'Tappy'
local Tile = require 'Tile'
local Util = require 'Util'

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

  local function _titleRow(y, s)
    local titleGroup = display.newGroup()
    -- the first tile is dim.halfQ over to the right
    titleGroup.x = display.contentCenterX - (string.len(s) * dim.halfQ) - dim.halfQ
    titleGroup.y = y
    sceneGroup:insert(titleGroup)

    local x = dim.Q
    for i=1, string.len(s) do
      local tileGroup = Tile.createGraphics(x, 0, string.sub(s, i, i))
      titleGroup:insert(tileGroup)
      x = x + dim.Q
    end
  end

  local function _tappyRow(y, s, mode)
    local tappyGroup = display.newGroup()
    -- the first tile is dim.halfQ over to the right
    tappyGroup.x = display.contentCenterX - (string.len(s) * dim.halfQ) - dim.halfQ
    tappyGroup.y = y
    sceneGroup:insert(tappyGroup)

    local x = dim.Q
    for i=1, string.len(s) do
      local tappy = Tappy.new(tappyGroup, x, 0, function()
        Util.sound('ui')
        _G.GAME_MODE = mode
        composer.gotoScene('Twitty', {effect='slideLeft'})
      end, string.sub(s, i, i)) -- no description
      x = x + dim.Q
    end
  end

  Util.setBackground(sceneGroup)

  local y = dim.Q

  _titleRow(y, 'TWITTY')

  y = y + dim.Q

  _titleRow(y, ({'LITTLE', 'LYTTLE'})[math.random(1, 2)])

  y = y + dim.Q

  _titleRow(y, ({'WORDES', 'SWORDS', 'WOORDS', 'VVORDS'})[math.random(1, 4)])

  y = (display.actualContentHeight / 2)
  _tappyRow(y, 'CASUAL', 'untimed')
  y = y + dim.Q * 0.75
  local help1 = display.newText(sceneGroup, 'Clear all tiles in your own time', display.contentCenterX, y, _G.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help1:setFillColor(0,0,0)

  y = (display.actualContentHeight / 2) + dim.Q + dim.Q
  _tappyRow(y, 'URGENT', 'timed')
  y = y + dim.Q * 0.75
  local help2 = display.newText(sceneGroup, 'Get your best score in four minutes', display.contentCenterX, y, _G.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help2:setFillColor(0,0,0)

  y = (display.actualContentHeight / 2) + dim.Q + dim.Q + dim.Q + dim.Q
  _tappyRow(y, 'TWELVE', 12)
  y = y + dim.Q * 0.75
  local help3 = display.newText(sceneGroup, 'Get your best score with twelve words', display.contentCenterX, y, _G.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help3:setFillColor(0,0,0)

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
  composer.removeScene('ModeMenu')
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
