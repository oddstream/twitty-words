
-- FoundWords.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local widget = require('widget')
local scene = composer.newScene()

-- local widget = require('widget')

local Tile = require 'Tile'
local Util = require 'Util'

local tiles = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function backTouch(event)

  local grp = event.target

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y)

  elseif event.phase == 'moved' then
    -- trace('touch moved, start', event.xStart, event.yStart, 'now', event.x, event.y)

    -- grp.x = event.x - event.xStart
    grp.y = event.y - event.yStart
  elseif event.phase == 'ended' then
    -- trace('touch ended', event.x, event.y)

    transition.moveTo(grp, {
      y = 0,
      transition = easing.outQuart,
    })
  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.yet)

  end

  return true

end

-- create()
function scene:create(event)

  local dim = _G.DIMENSIONS
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  -- trace('scene height is', sceneGroup.height)
  -- sceneGroup.height = display.actualContentHeight * 2
  -- trace('scene height is', sceneGroup.height)
  Util.setBackground(sceneGroup)
  sceneGroup:addEventListener('touch', backTouch)

  local function _createTile(x, y, txt)
    local grp = Tile.createGraphics(x, y, txt)
    sceneGroup:insert(grp)
    grp:scale(0.5, 0.5)
    table.insert(tiles, grp)
    return grp
  end


  -- the background needs to be tall enough to display #_G.grid.words
  -- local backHeight = (#_G.grid.words * dim.halfQ) + display.actualContentHeight

  -- local rectBackground = display.newRect(backGroup, display.actualContentWidth / 2, display.actualContentHeight / 2, display.actualContentWidth, backHeight)
  -- rectBackground:setFillColor(unpack(_G.MUST_COLORS.baize))

  local height = _G.DIMENSIONS.toolBarHeight
  local halfHeight = height / 2

  local rect = display.newRect(sceneGroup, display.contentCenterX, halfHeight, display.actualContentWidth, height)
  rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  local backButton = widget.newButton({
    x = dim.halfQ,
    y = halfHeight,
    onRelease = function()
      composer.hideOverlay('slideLeft')
      _G.grid:resumeCountdown()
    end,
    label = '< BACK',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'left',
    font = _G.TILE_FONT,
    fontSize = dim.halfQ,
    textOnly = true,
  })
  backButton.anchorX = 0
  sceneGroup:insert(backButton)

  local finishButton = widget.newButton({
    x = display.actualContentWidth - dim.halfQ,
    y = halfHeight,
    onRelease = function()
      composer.hideOverlay()
      _G.grid:gameOver()
    end,
    label = 'FINISH >',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'right',
    font = _G.TILE_FONT,
    fontSize = dim.halfQ,
    textOnly = true,
  })
  finishButton.anchorX = 1
  sceneGroup:insert(finishButton)

  tiles = {}

  local y = dim.toolBarHeight + dim.halfQ

  for i,word in ipairs(_G.grid.words) do

    local score = 0
    local xNumber = dim.halfQ
    local xScore = dim.halfQ
    local xLetter = dim.halfQ * 3

    if type(_G.GAME_MODE) == 'number' then
      _createTile(xNumber, y, tostring(i))
      xScore = xScore + dim.halfQ * 2
      xLetter = xLetter + dim.halfQ * 2
    end

    for j=1, string.len(word) do
      local letter = string.sub(word, j, j)
      score = score + _G.SCRABBLE_SCORES[letter]
      _createTile(xLetter, y, letter)
      xLetter = xLetter + dim.halfQ
    end

    _createTile(xScore, y, tostring(score * string.len(word)))
    y = y + dim.halfQ
  end

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
    -- composer.removeScene('FoundWords')
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  -- assert(Runtime:removeEventListener('key', scene))
end
--[[
function scene:key(event)
  local phase = event.phase
  if phase == 'up' then
    if event.keyName == 'back' or event.keyName == 'deleteBack' then
      composer.hideOverlay()
      return true -- override the key
    end
  end
end
]]
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

-- Runtime:addEventListener('key', scene)
-- -----------------------------------------------------------------------------------

return scene
