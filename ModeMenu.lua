
-- ModeMenu.lua

local composer = require('composer')
local scene = composer.newScene()

local const = require 'constants'

local globalData = require 'globalData'
local Dim = require 'Dim'

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

  trace('ModeMenu scene:create')

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  Util.setBackground(sceneGroup)
  local dim = Dim.new(7, 7)  -- pretend we are on a 7x7 grid
  globalData.dim = dim  -- used by Tile

  local function _titleRow(y, s)
    local titleGroup = display.newGroup()
    titleGroup.x = display.contentCenterX - (string.len(s) * dim.halfQ)
    titleGroup.y = y
    sceneGroup:insert(titleGroup)

    local x = dim.halfQ
    for i=1, string.len(s) do
      Tile.createGraphics(titleGroup, x, 0, string.sub(s, i, i))
      x = x + dim.Q
    end
  end

  local function _tappyRow(y, s, mode)
    local tappyGroup = display.newGroup()
    tappyGroup.x = display.contentCenterX - (string.len(s) * dim.halfQ)
    tappyGroup.y = y
    sceneGroup:insert(tappyGroup)

    -- the first tile is dim.halfQ over to the right
    local x = dim.halfQ
    for i=1, string.len(s) do
      local tappy = Tappy.new(tappyGroup, x, 0, function()
        Util.sound('ui')
        composer.gotoScene('Twitty', {effect='slideLeft', params={mode=mode}})
      end, string.sub(s, i, i)) -- no description
      x = x + dim.Q
    end
  end

  local y = dim.topInset + dim.Q

  _titleRow(y, 'TWITTY')

  y = y + dim.Q

  _titleRow(y, ({'WORDES', 'SWORDS', 'WOORDS', 'VVORDS'})[math.random(1, 4)])

  y = (display.actualContentHeight / 2) - (dim.Q * 2)

  for k,v in pairs(const.VARIANT) do
    trace('VARIANT', k, v)
    _tappyRow(y, k, k)
    y = y + dim.Q * 0.75
    local help1 = display.newText(sceneGroup, v.description, display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
    help1:setFillColor(0,0,0)
    y = y + dim.Q
  end
--[[
  _tappyRow(y, 'CASUAL', 'CASUAL')
  y = y + dim.Q * 0.75
  local help1 = display.newText(sceneGroup, 'Get your best score in your own time', display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help1:setFillColor(0,0,0)

  y = (display.actualContentHeight / 2)
  _tappyRow(y, 'URGENT', 'URGENT')
  y = y + dim.Q * 0.75
  local help2 = display.newText(sceneGroup, 'Get your best score in four minutes', display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help2:setFillColor(0,0,0)

  y = (display.actualContentHeight / 2) + (dim.Q * 2)
  _tappyRow(y, 'FILLUP', 'FILLUP')
  y = y + dim.Q * 0.75
  local help3 = display.newText(sceneGroup, 'Find words faster than new tiles are added', display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help3:setFillColor(0,0,0)

  -- y = (display.actualContentHeight / 2) + (dim.Q * 2)
  -- _tappyRow(y, 'TWELVE', 12)
  -- y = y + dim.Q * 0.75
  -- local help3 = display.newText(sceneGroup, 'Get your best score with twelve words', display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  -- help3:setFillColor(0,0,0)

  y = (display.actualContentHeight / 2) + (dim.Q * 4)
  _tappyRow(y, 'ROBOTO', 'ROBOTO')
  y = y + dim.Q * 0.75
  local help4 = display.newText(sceneGroup, 'Score 420 before the robot can', display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  help4:setFillColor(0,0,0)
]]
  local ver = display.newText(sceneGroup, system.getInfo('appVersionString'), display.contentCenterX, display.contentHeight - dim.tileFontSize / 3, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
  ver:setFillColor(0,0,0)
end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  trace('ModeMenu scene:show', event.phase)

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    if not Runtime:addEventListener('key', scene) then
      trace('ERROR: could not addEventListener key in ModeMenu scene:show')
    end
  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  trace('ModeMenu scene:hide', event.phase)

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    if not Runtime:removeEventListener('key', scene) then
      trace('ERROR: could not removeEventListener key in ModeMenu scene:hide')
    end
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  trace('ModeMenu scene:destroy')
  composer.removeScene('ModeMenu')
end

function scene:key(event)
  local phase = event.phase

  local function _exitListener(_event)
    if _event.action == 'clicked' then
      if _event.index == 1 then
        native.requestExit()
      end
    end
  end

  if phase == 'up' then
    if event.keyName == 'back' or event.keyName == 'deleteBack' then
      native.showAlert(
        system.getInfo('appName'),
        'Do you want to exit ' .. system.getInfo('appName') .. '?',
        {'Yes', 'No'},
        _exitListener)
      return true -- override the key
    end
  end

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
