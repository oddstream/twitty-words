
-- FoundWords.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local scene = composer.newScene()

-- local widget = require('widget')

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

  local dim = _G.DIMENSIONS
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  -- trace('scene height is', sceneGroup.height)
  -- sceneGroup.height = display.actualContentHeight * 2
  -- trace('scene height is', sceneGroup.height)
  Util.setBackground(sceneGroup)
  sceneGroup:addEventListener('touch', backTouch)

  local function _createTile(x, y, txt)
    local grp = Tile.createGraphics(sceneGroup, x, y, txt)
    grp:scale(0.5, 0.5)
    return grp
  end

  local function _displayRow(y, i, word)
    local score = 0
    local xNumber = dim.firstTileX + dim.halfQ
    local xScore = dim.firstTileX + dim.halfQ
    local xLetter = dim.firstTileX + (dim.halfQ * 3)

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
  end

  -- don't need this if using a bitmap background
  -- the background needs to be tall enough to display #_G.grid.words
  -- local backHeight = (#_G.grid.words * dim.halfQ) + display.actualContentHeight
  -- local rectBackground = display.newRect(sceneGroup, display.actualContentWidth / 2, display.actualContentHeight / 2, display.actualContentWidth, backHeight)
  -- rectBackground:setFillColor(unpack(_G.TWITTY_COLORS.baize))
--[[
  local rect = display.newRect(sceneGroup, dim.toolbarX, dim.toolbarY, dim.toolbarWidth, dim.toolbarHeight)
  rect:setFillColor(unpack(_G.TWITTY_COLORS.uibackground))
]]

--[[
  local backButton = widget.newButton({
    x = dim.firstTileX + dim.halfQ,
    y = dim.toolbarY,
    onRelease = function()
      Util.sound('ui')
      composer.hideOverlay('slideLeft')
      _G.grid:resumeCountdown()
    end,
    label = '< BACK',
    labelColor = { default=_G.TWITTY_COLORS.uiforeground, over=_G.TWITTY_COLORS.uicontrol },
    labelAlign = 'left',
    font = _G.ACME,
    fontSize = dim.toolbarHeight / 2,
    textOnly = true,
  })
  backButton.anchorX = 0
  sceneGroup:insert(backButton)
]]

    -- create a group for the tappy so it doesn't scroll with the background
  toolbarGroup = display:newGroup()

  local tappyBack = Tappy.new(toolbarGroup, dim.halfQ, dim.toolbarY, function()
    Util.sound('ui')
    composer.hideOverlay('slideLeft')
    _G.grid:resumeCountdown()
    end, '←', 'BACK')

  --[[
  local scales = display.newText({
    parent = toolbarGroup,
    x = dim.toolbarX,
    y = dim.toolbarY,
    text = '⚖',
    font = _G.ACME,
    fontSize = dim.toolbarHeight / 2,
  })
  scales:setFillColor(unpack(_G.TWITTY_COLORS.black))
]]

--[[
  local finishButton = widget.newButton({
    x = display.actualContentWidth - dim.halfQ,
    y = dim.toolbarY,
    onRelease = function()
      composer.hideOverlay()
      _G.grid:gameOver()
    end,
    label = 'FINISH >',
    labelColor = { default=_G.TWITTY_COLORS.uiforeground, over=_G.TWITTY_COLORS.uicontrol },
    labelAlign = 'right',
    font = _G.ACME,
    fontSize = dim.toolbarHeight / 2,
    textOnly = true,
  })
  finishButton.anchorX = 1
  sceneGroup:insert(finishButton)
]]

  local y = dim.halfQ

  for i,word in ipairs(_G.grid.humanFoundWords) do
    _displayRow(y, i, word)
    y = y + dim.halfQ
  end

  if _G.GAME_MODE == 'ROBOTO' then
    y = y + dim.Q
    for i,word in ipairs(_G.grid.robotFoundWords) do
      _displayRow(y, i, word)
      y = y + dim.halfQ
    end
  end

  local tappyFinish = Tappy.new(toolbarGroup, display.actualContentWidth - dim.halfQ, dim.toolbarY, function()
    Util.sound('ui')
    composer.hideOverlay()
    _G.grid:gameOver()
    end, ' ⚖ ', 'FINISH') -- '⯈' didn't appear on the phone

end


-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    -- assert(Runtime:addEventListener('key', scene))
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
    -- Runtime.removeEventListener('key', scene)

  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    toolbarGroup:removeSelf()
    -- delete the scene so it gets built next time it's shown
    composer.removeScene('FoundWords')
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
end

-- function scene:key(event)
--   local phase = event.phase
--   if phase == 'up' then
--     if event.keyName == 'back' or event.keyName == 'deleteBack' then
--       composer.hideOverlay()
--       return true -- override the key
--     end
--   end
-- end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)
-- -----------------------------------------------------------------------------------

return scene
