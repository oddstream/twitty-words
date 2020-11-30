
-- RobotEnd.lua

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

  Util.setBackground(sceneGroup)

  local function _titleRow(y, s)
    local titleGroup = display.newGroup()
    -- the first tile is dim.quarterQ over to the right
    titleGroup.x = display.contentCenterX - (string.len(s) * dim.quarterQ) - dim.quarterQ
    titleGroup.y = y
    sceneGroup:insert(titleGroup)

    local x = dim.halfQ
    for i=1, string.len(s) do
      local tileGroup = Tile.createGraphics(titleGroup, x, 0, string.sub(s, i, i))
      tileGroup:scale(0.5, 0.5)
      x = x + dim.halfQ
    end
  end

  local function _banner(y, s)
    local txt = display.newText({
      parent = sceneGroup,
      text = s,
      x = display.contentCenterX,
      y = y,
      font = _G.ACME,
      fontSize = dim.halfQ,
      align = 'center',
    })
    -- txt.anchorX = 0
    txt:setFillColor(0,0,0)
  end

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

  local y = dim.halfQ

  _banner(y, string.format('%d : %d', event.params.humanScore, event.params.robotScore))

  y = y + dim.Q

  if event.params.humanScore > event.params.robotScore then
    _titleRow(y, 'HUMAN WINS')
    Util.sound('complete')
  elseif event.params.humanScore < event.params.robotScore then
    _titleRow(y, 'ROBOTO WINS')
    Util.sound('failure')
  else
    _titleRow(y, 'GAME TIED')
  end

  y = y + dim.Q

  _banner(y, 'WORDS YOU FOUND')

  y = y + dim.Q

  for i,word in ipairs(event.params.humanFoundWords) do
    _displayRow(y, i, word)
    y = y + dim.halfQ
  end

  if _G.GAME_MODE == 'ROBOTO' then
    y = y + dim.Q
    _banner(y, 'WORDS ROBOTO FOUND')
    y = y + dim.Q
    for i,word in ipairs(event.params.robotFoundWords) do
      _displayRow(y, i, word)
      y = y + dim.halfQ
    end
  end

    -- create a group for the tappy so it doesn't scroll with the background
  toolbarGroup = display:newGroup()

  local tappy = Tappy.new(toolbarGroup, display.actualContentWidth - dim.halfQ, dim.toolbarY, function()
    Util.sound('ui')
    composer.gotoScene('Twitty', {effect='slideLeft'})
  end, 'Ne', 'NEW') -- '★'

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
      trace('ERROR: could not removeEventListener key in RobotEnd scene:hide')
    end

  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    toolbarGroup:removeSelf()
    -- delete the scene so it gets built next time it's shown
    composer.removeScene('RobotEnd')
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
      composer.gotoScene('Twitty', {effect='slideLeft'})
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
