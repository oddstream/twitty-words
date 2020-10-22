
-- FoundWords.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local widget = require('widget')
local scene = composer.newScene()

-- local widget = require('widget')

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
    -- local xStart = math.random(0, display.contentWidth)
    -- local yStart = math.random(0, display.contentHeight)
    local grp = Tile.createGraphics(x, y, txt)
    sceneGroup:insert(grp)
    grp:scale(0.5, 0.5)
    return grp
  end

  local rect = display.newRect(sceneGroup, display.contentWidth / 2, display.contentHeight / 2, display.contentWidth, display.contentHeight)
  rect:setFillColor(unpack(_G.MUST_COLORS.ivory))
  rect.alpha = 0.9

  local y = dim.toolBarHeight + dim.Q50

  for _,word in ipairs(_G.grid.words) do

    local score = 0
    local x = dim.Q50 * 3

    for j=1, string.len(word) do
      local letter = string.sub(word, j, j)
      score = score + _G.SCRABBLE_SCORES[letter]
      _createTile(x, y, letter)
      x = x + dim.Q50
    end

    _createTile(dim.Q50, y, tostring(score * string.len(word)), false)
    y = y + dim.Q50
  end

  local height = _G.DIMENSIONS.toolBarHeight
  local halfHeight = height / 2

  rect = display.newRect(sceneGroup, display.contentCenterX, halfHeight, display.contentWidth, height)
  rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  local backButton = widget.newButton({
    x = dim.Q,
    y = halfHeight,
    onRelease = function()
      composer.hideOverlay()
    end,
    label = '< BACK',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'left',
    font = _G.TILE_FONT,
    fontSize = dim.Q50,
    textOnly = true,
  })
  sceneGroup:insert(backButton)

  local finishButton = widget.newButton({
    x = display.contentWidth - dim.Q,
    y = halfHeight,
    onRelease = function()
      composer.hideOverlay()
      _G.grid:gameOver()
      end,
    label = 'FINISH >',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'right',
    font = _G.TILE_FONT,
    fontSize = dim.Q50,
    textOnly = true,
  })
  sceneGroup:insert(finishButton)
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
    composer.removeScene('FoundWords')
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
