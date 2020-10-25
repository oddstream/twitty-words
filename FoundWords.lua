
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

local function flyAwayTiles()

  for _,grp in ipairs(tiles) do
    local dx, dy = Util.randomDirections()
    transition.moveTo(grp, {
      x = dx,
      y = dy,
      time = _G.FLIGHT_TIME,
      transition = easing.outQuart,
    })
  end

end

-- create()
function scene:create(event)

  local dim = _G.DIMENSIONS
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local function _createTile(x, y, txt)
    local grp = Tile.createGraphics(x, y, txt)
    sceneGroup:insert(grp)
    grp:scale(0.5, 0.5)
    table.insert(tiles, grp)
    return grp
  end

  local rectBackground = display.newRect(sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight)
  rectBackground:setFillColor(unpack(_G.MUST_COLORS.baize))
  -- rectBackground.alpha = 0
  -- transition.fadeIn(rectBackground, {
  --   time = _G.FLIGHT_TIME
  -- })

  local height = _G.DIMENSIONS.toolBarHeight
  local halfHeight = height / 2

  local rect = display.newRect(sceneGroup, display.contentCenterX, halfHeight, display.contentWidth, height)
  rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  local backButton = widget.newButton({
    x = 0,
    y = halfHeight,
    onRelease = function()
      -- flyAwayTiles()
      -- transition.fadeOut(rectBackground, {
        -- time = _G.FLIGHT_TIME,
        -- onComplete = function()
          composer.hideOverlay('slideLeft')
        -- end
      -- })
    end,
    label = ' < BACK',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'left',
    font = _G.TILE_FONT,
    fontSize = dim.halfQ,
    textOnly = true,
  })
  backButton.anchorX = 0
  sceneGroup:insert(backButton)

  local finishButton = widget.newButton({
    x = display.contentWidth,
    y = halfHeight,
    onRelease = function()
      -- flyAwayTiles()
      -- transition.fadeOut(rectBackground, {
        -- time = _G.FLIGHT_TIME / 2,
        -- onComplete = function()
          composer.hideOverlay()
          _G.grid:gameOver()
        -- end
      -- })
    end,
    label = 'FINISH > ',
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

  for _,word in ipairs(_G.grid.words) do

    local score = 0
    local x = dim.halfQ * 3

    for j=1, string.len(word) do
      local letter = string.sub(word, j, j)
      score = score + _G.SCRABBLE_SCORES[letter]
      _createTile(x, y, letter)
      x = x + dim.halfQ
    end

    _createTile(dim.halfQ, y, tostring(score * string.len(word)))
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

function scene:key(event)
  local phase = event.phase
  if phase == 'up' then
    if event.keyName == 'back' or event.keyName == 'deleteBack' then
      composer.hideOverlay()
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

Runtime:addEventListener('key', scene)
-- -----------------------------------------------------------------------------------

return scene
