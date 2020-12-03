
-- HighScores.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local scene = composer.newScene()

-- local widget = require('widget')
local json = require('json')

local const = require 'constants'

local Tappy = require 'Tappy'
local Tile = require 'Tile'
local Util = require 'Util'

local toolbarGroup

local filePath = system.pathForFile(_G.GAME_MODE .. '_scores.json', system.DocumentsDirectory)
-- win32 c:\Users\oddst\AppData\Roaming\Wychwood Paddocks\Must\Documents
-- print(filePath)

local function loadScores()
  local scoresTable
  local file = io.open(filePath, 'r')

  if file then
    local contents = file:read('*a')
    io.close(file)
    scoresTable = json.decode(contents)
  end

  if scoresTable == nil or #scoresTable == 0 then

    local interestingWords = {
      -- maximum length without overflowing to right is 11
      'TELEVISION',
      'SERENDIPITY',
      'SHENANIGANS',
      'BAMBOOZLE',
      'BODACIOUSLY',
      'VIXENISH',
      'ZIPPERS',
      'BROUHAHA',
      'SCRUMPTIOUS',
      'CANOODLE',
      'PETRICHOR',
      'NIMCOMPOOP',
      'MALARKEY',
      'ZOOMING',
      'ZOOMORPHISM',
      'NETWORKERS',
      'DAUGHTERS',
      'CONTAINERS',
      'INCLUDING',
      'RACCOONS',
      'ZOMBIES',
      'QUIVERS',
      'ALPHABETS',
      'ALPENSTOCKS',
      'ALUMSTONES',
      'MOSQUITO',
      'SIAMEZING',
      'SLEEZIEST',
      'ANTICRUELTY',
      'ODDSMAKERS',
      'VIEWPOINT',
      'YEARLINGS',
      'WAVEFRONT',
      'MAGAZINES',
      'VAGABONDS',
      'ROADHOUSES',
      'SOCIALIZE',
      'MAGAZINES',
      'QUARTERED',
      'SLEUTHING',
    }

    scoresTable = {}
    for score = 1000, 50, -50 do
      local word = table.remove(interestingWords, math.random(1,#interestingWords))
      table.insert(scoresTable, {score=score, words={word}})
    end
  end
  return scoresTable
end

local function saveScores(scoresTable)
  for i = #scoresTable, 21, -1 do
    table.remove(scoresTable, i)
  end

  local file = io.open(filePath, 'w')

  if file then
    -- trace('write', filePath, json.encode(scoresTable))
    file:write(json.encode(scoresTable))
    io.close(file )
  end
end

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

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  trace('HighScores scene:create')
  Util.setBackground(sceneGroup)

end


-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  local dim = _G.DIMENSIONS

  trace('HighScores scene:show', phase)

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    local scoresTable = loadScores()

    local score = nil
    local words = nil

    if event.params then
      score = event.params.score
      -- trace('score', score)
      words = event.params.words
      -- trace('words', words)

      if score and words then

        table.insert(scoresTable, {score=score, words=words})

        table.sort(scoresTable, function(a,b) return a.score > b.score end) -- default comp uses <

        if score > scoresTable[#scoresTable].score then
          -- trace('writing scores')
          saveScores(scoresTable)
        -- else
        --   trace('worthless new score')
        end

      end
    end

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

    local function _showScoreAndWord(thisScore, thisWord, yPos, color)
      Tile.createLittleGraphics(sceneGroup, dim.halfQ, yPos, tostring(thisScore), color)
      local x = dim.firstTileX + (dim.halfQ * 3)
      for j=1, string.len(thisWord) do
        Tile.createLittleGraphics(sceneGroup, x, yPos, string.sub(thisWord, j, j), color)
        x = x + dim.halfQ
      end
    end

    local y = dim.halfQ

    _banner(y, 'HIGH SCORES')

    y = y + dim.Q

    for i = 1, 20 do
      if scoresTable[i] then
        -- show the highest scoring word, which has been sorted (when inserted) to the front
        if scoresTable[i].score == score then
          _showScoreAndWord(scoresTable[i].score, scoresTable[i].words[1], y, const.COLORS.selected)
        else
          _showScoreAndWord(scoresTable[i].score, scoresTable[i].words[1], y, const.COLORS.tile)
        end
        y = y + dim.halfQ
      end
    end

    -- show the user's pathetic effort if it's not in the top 20
    if #words > 0 then
      if score < scoresTable[20].score then
        Util.sound('failure')
        y = y + dim.halfQ
        _showScoreAndWord(score, words[1], y, const.COLORS.selected)
      else
        Util.sound('complete')
      end
    end

    sceneGroup:addEventListener('touch', backTouch)

    if not Runtime:addEventListener('key', scene) then
      trace('ERROR: could not addEventListener key in HighScores scene:show')
    end

  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen

    -- create a group for the tappy so it doesn't scroll with the background
    toolbarGroup = display:newGroup()
    local tappy = Tappy.new(toolbarGroup, display.actualContentWidth - dim.halfQ, dim.toolbarY, function()
      Util.sound('ui')
      composer.gotoScene('Twitty', {effect='slideRight'})
    end, 'Ne', 'NEW') -- '★'

  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  trace('HighScores scene:hide', phase)

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    sceneGroup:removeEventListener('touch', backTouch)

    if not Runtime:removeEventListener('key', scene) then
      trace('ERROR: could not removeEventListener key in HighScores scene:hide')
    end

  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    toolbarGroup:removeSelf()
    --- delete the scene so it gets built next time it's shown
    composer.removeScene('HighScores')
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  trace('HighScores scene:destroy')
end

function scene:key(event)
  local phase = event.phase
  if phase == 'up' then
    if event.keyName == 'back' or event.keyName == 'deleteBack' then
      Util.sound('ui')
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
