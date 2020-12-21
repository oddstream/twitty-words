
-- ModeMenu.lua

local composer = require('composer')
local scene = composer.newScene()
-- local utf8 = require 'plugin.utf8'  -- https://docs.coronalabs.com/plugin/utf8/index.html

local const = require 'constants'

local globalData = require 'globalData'
local Dim = require 'Dim'

local Ivory = require 'Ivory'
local Tappy = require 'Tappy'
local Util = require 'Util'

local genericMore

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

local function backTouch(event)

  local grp = event.target

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y)

  elseif event.phase == 'moved' then
    -- trace('touch moved, start', event.xStart, event.yStart, 'now', event.x, event.y)

    grp.x = event.x - event.xStart
    grp.y = event.y - event.yStart

  elseif event.phase == 'ended' then
    -- trace('touch ended', event.x, event.y)

    -- transition.moveTo(grp, {x = 0, y = 0, transition = easing.outQuad })

    if genericMore then
      genericMore:removeSelf()
      genericMore = nil
    end

  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.yet)

    transition.moveTo(grp, {x = 0, y = 0, transition = easing.outQuad })

  end

  return true

end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

  trace('ModeMenu scene:create')

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  -- don't build the scene here
  -- because we want it to reload if the palette has changed

end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  trace('ModeMenu scene:show', event.phase)

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
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
        Ivory.new({
          parent = titleGroup,
          x = x,
          y = 0,
          text = string.sub(s, i, i)
        })
        x = x + dim.Q
      end
    end

    local function _tappyModeRow(y, mode)
      local tappyGroup = display.newGroup()
      tappyGroup.x = display.contentCenterX - (string.len(mode) * dim.halfQ)
      tappyGroup.y = y
      sceneGroup:insert(tappyGroup)

      -- the first tile is dim.halfQ over to the right
      local x = dim.halfQ
      for i=1, string.len(mode) do
        Tappy.new({
          parent = tappyGroup,
          x = x,
          y = 0,
          command = function()
            Util.sound('ui')
            composer.gotoScene('Twitty', {effect='slideLeft', params={mode=mode}})
          end,
          text = string.sub(mode, i, i),
          -- no description
        })
        x = x + dim.Q
      end
    end

    local function _tappySceneRow(y, s, scn)
      local tappyGroup = display.newGroup()
      tappyGroup.x = display.contentCenterX - (string.len(s) * dim.halfQ)
      tappyGroup.y = y
      sceneGroup:insert(tappyGroup)

      local x = dim.halfQ
      for i=1, string.len(s) do
        local ch = string.sub(s, i, i)
        Tappy.new({
          parent = tappyGroup,
          x = x,
          y = 0,
          command = function()
            Util.sound('ui')
            composer.gotoScene(scn, {effect='slideLeft'})
          end,
          text = ch,
        })
        x = x + dim.Q
      end
    end

    local y = dim.topInset + dim.Q

    _titleRow(y, 'TWITTY')

    y = y + dim.Q

    _titleRow(y, ({'WORDES', 'SWORDS', 'WOORDS', 'VVORDS'})[math.random(1, 4)])

    y = y + dim.Q + dim.halfQ

    for k,v in pairs(const.VARIANT) do
      -- trace('VARIANT', k, v)
      _tappyModeRow(y, k)
      y = y + dim.Q * 0.75
      local help1 = display.newText(sceneGroup, v.description, display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
      help1:setFillColor(0,0,0)
      y = y + dim.Q
    end

    do
      _tappySceneRow(y, 'COLORS', 'ColorMenu')
      y = y + dim.Q * 0.75
      local help1 = display.newText(sceneGroup, 'Set the screen colors', display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
      help1:setFillColor(0,0,0)
      y = y + dim.Q
    end

    local ver = display.newText(sceneGroup, system.getInfo('appVersionString'), display.contentCenterX, y, const.FONTS.ROBOTO_MEDIUM, dim.tileFontSize / 3)
    ver:setFillColor(0,0,0)

    if y > display.contentHeight then genericMore = Util.genericMore(sceneGroup, 'right') end

      sceneGroup:addEventListener('touch', backTouch)
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
    sceneGroup:removeEventListener('touch', backTouch)
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
    elseif event.keyName == 'c' then
      composer.gotoScene('ColorMenu', {effect='slideLeft'})
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
