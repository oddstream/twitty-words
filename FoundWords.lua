
-- FoundWords.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local scene = composer.newScene()

-- local widget = require('widget')

local const = require 'constants'
local globalData = require 'globalData'

local Ivory = require 'Ivory'
local Tappy = require 'Tappy'
local Util = require 'Util'

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

local tappiesGroup

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

  local function _displayRow(y, i, word, color)
    local score = 0
    -- local xNumber = dim.firstTileX + dim.halfQ
    local xScore = dim.firstTileX + dim.halfQ
    local xLetter = dim.firstTileX + (dim.halfQ * 3)

    -- if type(globalData.mode) == 'number' then
    --   Tile.createLittleGraphics(sceneGroup, xNumber, y, tostring(i), color)
    --   xScore = xScore + dim.halfQ * 2
    --   xLetter = xLetter + dim.halfQ * 2
    -- end

    for j=1, string.len(word) do
      local letter = string.sub(word, j, j)
      score = score + const.SCRABBLE_SCORES[letter]
      Ivory.new({
        parent = sceneGroup,
        x = xLetter,
        y = y,
        text = letter,
        color = color,
        scale = 0.5
      })
      xLetter = xLetter + dim.halfQ
    end

    Ivory.new({
      parent = sceneGroup,
      x = xScore,
      y = y,
      text = tostring(score * string.len(word)),
      color = color,
      scale = 0.5
    })
  end

--[[
  local rect = display.newRect(sceneGroup, dim.toolbarX, dim.toolbarY, dim.toolbarWidth, dim.toolbarHeight)
  rect:setFillColor(unpack(const.COLORS.uibackground))
]]

  local y = dim.topInset + dim.halfQ

  Util.banner(sceneGroup, y, 'WORDS YOU FOUND')

  y = y + dim.Q

  for i,word in ipairs(globalData.grid.humanFoundWords) do
    _displayRow(y, i, word, globalData.colorSelected)
    y = y + dim.halfQ
  end

  if globalData.grid.swapLoss > 0 then
    y = y + dim.Q
    Util.banner(sceneGroup, y, string.format('-%u SWAP POINTS', globalData.grid.swapLoss))
    y = y + dim.Q
  end

  if #globalData.grid.robotFoundWords > 0 then
    y = y + dim.Q
    Util.banner(sceneGroup, y, 'WORDS ROBOTO FOUND')
    y = y + dim.Q
    for i,word in ipairs(globalData.grid.robotFoundWords) do
      _displayRow(y, i, word, globalData.colorRoboto)
      y = y + dim.halfQ
    end
  end

  if y > display.contentHeight then Util.genericMore(sceneGroup) end

  local Tappies = {
    {element='back', label='<', subtitle='BACK', cmd=function()
      Util.sound('ui')
      composer.hideOverlay('slideLeft') -- default is recycleOnly=false, so overlay scene will be completely removed, including its scene object
      globalData.grid:resumeCountdown()
    end},
    {element='finish', label='Fin', subtitle='FINISH', cmd=function()
      Util.sound('ui')
      composer.hideOverlay('slideLeft') -- default is recycleOnly=false, so overlay scene will be completely removed, including its scene object
      globalData.grid:gameOver()
    end},
  }

  -- create a group for the tappies so they doesn't scroll with the background
  tappiesGroup = display:newGroup()
  -- sceneGroup:insert(tappiesGroup)
  local tappies = {}
  for i=1,#Tappies do
    local tp = Tappies[i]
    tappies[tp.element] = Tappy.new(
      tappiesGroup,
      Util.mapValue(i, 1, #Tappies, dim.halfQ, display.actualContentWidth - dim.halfQ),
      dim.toolbarY,
      tp.cmd,
      tp.label,
      tp.subtitle
    )
  end

  if const.VARIANT[globalData.mode].robot then  -- TODO this is ugly and smelly
    tappies.finish:enable(false)
  end

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
    tappiesGroup:removeSelf()
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
