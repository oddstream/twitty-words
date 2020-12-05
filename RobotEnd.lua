
-- RobotEnd.lua

local composer = require('composer')
local scene = composer.newScene()
local json = require 'json'

local const = require 'constants'
local globalData = require 'globalData'

local Tappy = require 'Tappy'
local Tile = require 'Tile'
local Util = require 'Util'

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

local filePath = system.pathForFile('ROBOTO_stats.json', system.DocumentsDirectory)

local function loadStats()
  local stats
  local file, msg = io.open(filePath, 'r')
  if file then
    local contents = file:read('*a')
    io.close(file)
    trace('robot stats loaded from', filePath)
    stats = json.decode(contents)
  else
    trace('cannot open', filePath, msg)
  end
  return stats or {
    gamesWon = 0,
    gamesLost = 0,
    bestScore = 0,
    worstScore = 9999,
    currStreak = 0,
    bestStreak = 0,
    worstStreak = 0,
  }
end

local function saveStats(stats)
  local file, msg = io.open(filePath, 'w')
  if file then
    file:write(json.encode(stats, {indent=true}))
    trace('robot stats written to', filePath)
    io.close(file)
  else
    trace('cannot open', filePath, msg)
  end
end


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

  Util.setBackground(sceneGroup)

  local function _titleRow(y, s)
    local titleGroup = display.newGroup()
    -- the first tile is dim.quarterQ over to the right
    titleGroup.x = display.contentCenterX - (string.len(s) * dim.quarterQ) - dim.quarterQ
    titleGroup.y = y
    sceneGroup:insert(titleGroup)

    local x = dim.halfQ
    for i=1, string.len(s) do
      Tile.createLittleGraphics(titleGroup, x, 0, string.sub(s, i, i))
      x = x + dim.halfQ
    end
  end

  local function _banner(y, s)
    local txt = display.newText({
      parent = sceneGroup,
      text = s,
      x = display.contentCenterX,
      y = y,
      font = const.FONTS.ACME,
      fontSize = dim.Q / 3,
      align = 'center',
    })
    -- txt.anchorX = 0
    txt:setFillColor(0,0,0)
  end

  local function _text(y, s)
    local txt = display.newText({
      parent = sceneGroup,
      text = s,
      x = display.contentCenterX,
      y = y,
      font = const.FONTS.ACME,
      fontSize = dim.Q / 4,
      align = 'center',
    })
    -- txt.anchorX = 0
    txt:setFillColor(0,0,0)
  end

  local function _displayRow(y, word, color)
    local score = 0

    local xScore = dim.firstTileX + dim.halfQ
    local xLetter = dim.firstTileX + (dim.halfQ * 3)

    for j=1, string.len(word) do
      local letter = string.sub(word, j, j)
      score = score + const.SCRABBLE_SCORES[letter]
      Tile.createLittleGraphics(sceneGroup, xLetter, y, letter, color)
      xLetter = xLetter + dim.halfQ
    end

    Tile.createLittleGraphics(sceneGroup, xScore, y, tostring(score * string.len(word)), color)
  end

  local stats = loadStats()

  local y = dim.halfQ

  if event.params.humanScore > event.params.robotScore then
    _titleRow(y, 'YOU WON')
    Util.sound('complete')

    stats.gamesWon = stats.gamesWon + 1

    if stats.currStreak < 0 then
      stats.currStreak = 1
    else
      stats.currStreak = stats.currStreak + 1
    end
    if stats.currStreak > stats.bestStreak then
      stats.bestStreak = stats.currStreak
    end

  elseif event.params.humanScore < event.params.robotScore then
    _titleRow(y, 'YOU LOSE')
    Util.sound('failure')

    stats.gamesLost = stats.gamesLost + 1

    if stats.currStreak > 0 then
      stats.currStreak = -1
    else
      stats.currStreak = stats.currStreak - 1
    end
    if stats.currStreak < stats.worstStreak then
      stats.worstStreak = stats.currStreak
    end

  else
    _titleRow(y, 'GAME TIED')
  end

  if event.params.humanScore > stats.bestScore then
    stats.bestScore = event.params.humanScore
  end
  if event.params.humanScore < stats.worstScore then
    stats.worstScore = event.params.humanScore
  end

  -- y = y + dim.halfQ

  -- _banner(y, string.format('%d : %d', event.params.humanScore, event.params.robotScore))

  y = y + dim.Q

  _text(y, string.format('GAMES WON: %u', stats.gamesWon))
  y = y + dim.quarterQ
  _text(y, string.format('GAMES LOST: %u', stats.gamesLost))
  y = y + dim.halfQ

  _text(y, string.format('BEST SCORE: %u', stats.bestScore))
  y = y + dim.quarterQ
  _text(y, string.format('WORST SCORE: %u', stats.worstScore))
  y = y + dim.halfQ

  _text(y, string.format('CURRENT STREAK: %d', stats.currStreak))
  y = y + dim.quarterQ
  _text(y, string.format('BEST STREAK: %d', stats.bestStreak))
  y = y + dim.quarterQ
  _text(y, string.format('WORST STREAK: %d', stats.worstStreak))
  y = y + dim.quarterQ

  saveStats(stats)

  y = y + dim.halfQ

  _banner(y, 'WORDS YOU FOUND')

  y = y + dim.halfQ

  for _,word in ipairs(event.params.humanFoundWords) do
    _displayRow(y, word, const.COLORS.selected)
    y = y + dim.halfQ
  end

  y = y + dim.halfQ

  _banner(y, 'WORDS ROBOTO FOUND')
  y = y + dim.halfQ
  for _,word in ipairs(event.params.robotFoundWords) do
    _displayRow(y, word, const.COLORS.roboto)
    y = y + dim.halfQ
  end

    -- create a group for the tappy so it doesn't scroll with the background
  toolbarGroup = display:newGroup()

  local tappy = Tappy.new(toolbarGroup, display.actualContentWidth - dim.halfQ, dim.toolbarY, function()
    Util.sound('ui')
    composer.gotoScene('Twitty', {effect='slideRight'})
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
      composer.gotoScene('Twitty', {effect='slideRight'})
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
