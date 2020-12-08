
-- FoundWords.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local scene = composer.newScene()

-- local widget = require('widget')

local const = require 'constants'
local globalData = require 'globalData'

local Tappy = require 'Tappy'
local Tile = require 'Tile'
local Util = require 'Util'

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

local toolbarGroup

-- -----------------------------------------------------------------------------------
-- Scene event functions
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

    transition.moveTo(grp, {x = 0, y = 0, transition = easing.outQuad })

  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.yet)

    transition.moveTo(grp, {x = 0, y = 0, transition = easing.outQuad })

  end

  return true

end

-- create()
function scene:create(event)

  local dim = globalData.dim
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  -- trace('scene height is', sceneGroup.height)
  -- sceneGroup.height = display.actualContentHeight * 2
  -- trace('scene height is', sceneGroup.height)
  Util.setBackground(sceneGroup)

  local function _banner(y, s)
    local txt = display.newText({
      parent = sceneGroup,
      text = s,
      x = display.contentCenterX,
      y = y,
      font = const.FONTS.ACME,
      fontSize = dim.halfQ,
      align = 'center',
    })
    -- txt.anchorX = 0
    txt:setFillColor(0,0,0)
  end

  local function _displayRow(y, i, word, color)
    local score = 0
    local xNumber = dim.firstTileX + dim.halfQ
    local xScore = dim.firstTileX + dim.halfQ
    local xLetter = dim.firstTileX + (dim.halfQ * 3)

    if type(globalData.mode) == 'number' then
      Tile.createLittleGraphics(sceneGroup, xNumber, y, tostring(i), color)
      xScore = xScore + dim.halfQ * 2
      xLetter = xLetter + dim.halfQ * 2
    end

    for j=1, string.len(word) do
      local letter = string.sub(word, j, j)
      score = score + const.SCRABBLE_SCORES[letter]
      Tile.createLittleGraphics(sceneGroup, xLetter, y, letter, color)
      xLetter = xLetter + dim.halfQ
    end

    Tile.createLittleGraphics(sceneGroup, xScore, y, tostring(score * string.len(word)), color)
  end

--[[
  local rect = display.newRect(sceneGroup, dim.toolbarX, dim.toolbarY, dim.toolbarWidth, dim.toolbarHeight)
  rect:setFillColor(unpack(const.COLORS.uibackground))
]]

  local y = dim.topInset + dim.halfQ

  _banner(y, 'WORDS YOU FOUND')

  y = y + dim.Q

  for i,word in ipairs(globalData.grid.humanFoundWords) do
    _displayRow(y, i, word, const.COLORS.selected)
    y = y + dim.halfQ
  end

  if globalData.mode == 'ROBOTO' then
    y = y + dim.Q
    _banner(y, 'WORDS ROBOTO FOUND')
    y = y + dim.Q
    for i,word in ipairs(globalData.grid.robotFoundWords) do
      _displayRow(y, i, word, const.COLORS.roboto)
      y = y + dim.halfQ
    end
  end

    -- create a group for the tappy so it doesn't scroll with the background
  toolbarGroup = display:newGroup()

  local tappyBack = Tappy.new(toolbarGroup, dim.halfQ, dim.toolbarY, function()
    Util.sound('ui')
    composer.hideOverlay('slideLeft') -- default is recycleOnly=false, so overlay scene will be completely removed, including its scene object
    globalData.grid:resumeCountdown()
    end, '<', 'BACK') -- '←'

  local tappyFinish = Tappy.new(toolbarGroup, display.actualContentWidth - dim.halfQ, dim.toolbarY, function()
    Util.sound('ui')
    composer.hideOverlay('slideLeft') -- default is recycleOnly=false, so overlay scene will be completely removed, including its scene object
    globalData.grid:gameOver()
    end, 'Fin', 'FINISH') -- '⯈' didn't appear on the phone, ' ⚖ '
  -- tappyFinish:enable(globalData.grid.humanCanFinish)

end


-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    sceneGroup:addEventListener('touch', backTouch)

    if not Runtime:addEventListener('key', scene) then
      trace('ERROR: could not addEventListener key in FoundWords scene:show')
    end
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
    sceneGroup:removeEventListener('touch', backTouch)

    if not Runtime:removeEventListener('key', scene) then
      trace('ERROR: could not removeEventListener key in FoundWords scene:hide')
    end

  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    toolbarGroup:removeSelf()
    -- delete the scene so it gets built next time it's shown
    -- composer.removeScene('FoundWords')
    -- "FoundWords's was not removed because it does not exist. Use composer.loadScene() or composer.gotoScene()"
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
end

function scene:key(event)
  local phase = event.phase
  if phase == 'up' then
    if event.keyName == 'back' or event.keyName == 'deleteBack' then
      Util.sound('ui')
      composer.hideOverlay('slideLeft')
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
