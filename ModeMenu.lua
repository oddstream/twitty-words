
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

-- TODO add a titlebar

-- create()
function scene:create(event)

  local dim = _G.DIMENSIONS
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local function _createTile(group, x, y, txt)
    local grp = Tile.createGraphics(x, y, txt)
    group:insert(grp)
    return grp
  end

  local function _titleLine(y, s)
    local titleGroup = display.newGroup()
    -- the first tile is dim.halfQ over to the right
    titleGroup.x = display.contentCenterX - (string.len(s) * dim.Q / 2) - (dim.Q / 2)
    titleGroup.y = y
    sceneGroup:insert(titleGroup)
    local x = dim.Q
    for i=1, string.len(s) do
      local tile = _createTile(titleGroup, x, dim.wordbarY, string.sub(s, i, i))
      titleGroup:insert(tile)
      x = x + dim.Q
    end
  end

  local function _createTappyRow(y, title, mode)
    local x = dim.Q
    for i=1, string.len(title) do
      local tappy = Tappy.new(sceneGroup, x, y, function()
        Util.sound('ui')
        _G.GAME_MODE = mode
        composer.gotoScene('Twitty', {effect='slideLeft'})
      end)
      tappy:setLabel(string.sub(title, i, i))
      x = x + dim.Q
    end
  end

  Util.setBackground(sceneGroup)

  local y = dim.halfQ

  _titleLine(y, 'LYTTLE')

  y = y + dim.Q

  _titleLine(y, 'TWITTY')

  y = y + dim.Q

  _titleLine(y, 'WORDES')

  y = (display.actualContentHeight / 2)
  _createTappyRow(y, 'VACATE', 'untimed')
  y = y + dim.Q * 0.75
  local help1 = display.newText(sceneGroup, 'Clear all tiles in your own time', display.contentCenterX, y, _G.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help1:setFillColor(0,0,0)

  y = (display.actualContentHeight / 2) + dim.Q + dim.Q
  _createTappyRow(y, 'URGENT', 'timed')
  y = y + dim.Q * 0.75
  local help2 = display.newText(sceneGroup, 'Get your best score in five minutes', display.contentCenterX, y, _G.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help2:setFillColor(0,0,0)

  y = (display.actualContentHeight / 2) + dim.Q + dim.Q + dim.Q + dim.Q
  _createTappyRow(y, 'TWELVE', 12)
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
