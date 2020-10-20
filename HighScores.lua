
-- HighScores.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local scene = composer.newScene()

local widget = require('widget')
local json = require('json')

local Tile = require 'Tile'

local scoresTable = {}

local filePath = system.pathForFile('scores.json', system.DocumentsDirectory)
-- win32 c:\Users\oddst\AppData\Roaming\Wychwood Paddocks\Must\Documents
-- print(filePath)

local function loadScores()
  local file = io.open(filePath, 'r')

  if file then
    local contents = file:read('*a')
    io.close(file)
    scoresTable = json.decode(contents)
  end

  if scoresTable == nil or #scoresTable == 0 then
    scoresTable = {
      -- https://www.ef.com/wwen/blog/language/funniest-words-in-english/
      {score=1000, words={'SHENANIGANS'}},
      {score=900, words={'BAMBOOZLE'}},
      {score=800, words={'BODACIOUS'}},
      {score=700, words={'BROUHAHA'}},
      {score=600, words={'CANOODLE'}},
      {score=500, words={'GNARLY'}},
      {score=400, words={'GOGGLE'}},
      {score=300, words={'GUBBINS'}},
      {score=200, words={'MALARKEY'}},
      {score=100, words={'NIMCOMPOOP'}},
    }
  end
end

local function saveScores()
  for i = #scoresTable, 11, -1 do
    table.remove(scoresTable, i)
  end

  local file = io.open(filePath, 'w')

  if file then
    trace('write', filePath, json.encode(scoresTable))
    file:write(json.encode(scoresTable))
    io.close(file )
  end
end

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()'
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function wordScoreComp(a, b)
  local function calcScore(s)
    local score = 0
    for i=1, string.len(s) do
      score = score + _G.SCRABBLE_SCORES[string.sub(s, i, i)]
    end
    return score * string.len(s)
  end
  return calcScore(a) > calcScore(b)
end

-- create()
function scene:create(event)

  local dim = _G.DIMENSIONS
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local function _createTile(x, y, txt, selected)
    -- local xStart = math.random(0, display.contentWidth)
    -- local yStart = math.random(0, display.contentHeight)
    local grp = Tile.createGraphics(x, y, txt)
    sceneGroup:insert(grp)
    grp:scale(0.5, 0.5)
    if selected then
      grp[2]:setFillColor(unpack(_G.MUST_COLORS.gold))
    end

    -- transition.moveTo(grp, {
    --   x = x,
    --   y = y,
    --   time = _G.FLIGHT_TIME,
    --   transition = easing.outQuart,
    -- })

    return grp
  end

    loadScores()

  local score = nil
  local words = nil

  if event.params then
    score = event.params.score
    -- trace('score', score)
    words = event.params.words
    -- trace('words', words)

    if score and words then

      -- sort the words once when they first arrive
      -- TODO make a better version of this which uses _G.SCRABBLE_SCORES
      -- table.sort(words, function(a,b) return string.len(a) > string.len(b) end)
      table.sort(words, wordScoreComp)

      table.insert(scoresTable, {score=score, words=words})

      table.sort(scoresTable, function(a,b) return a.score > b.score end) -- default comp uses <

      if score > scoresTable[#scoresTable].score then
        trace('writing scores')
        saveScores()
      else
        trace('worthless new score')
      end

    end
  end

  -- local bannerText = 'HIGH SCORES'
  -- if event.params and event.params.banner then
  --   bannerText = event.params.banner
  -- end

  local y = dim.Q50
  -- local highScoresBanner = display.newText(sceneGroup, bannerText, display.contentCenterX, y, native.systemFontBold, 72)
  -- y = y + dim.Q50

  -- if score then
  --   local infoText1 = string.format('SCORE %d', event.params.score)
  --   local displayText1 = display.newText(sceneGroup, infoText1, display.contentCenterX, y, native.systemFontBold, 72)
  --   displayText1:setFillColor(0,0,0)
  --   y = y + dim.Q50
  -- end

  for i = 1, 10 do
    if scoresTable[i] then
      _createTile(dim.Q50, y, tostring(scoresTable[i].score), scoresTable[i].score == score)

      do
        local x = dim.Q50 * 3
        local word = scoresTable[i].words[1]
        for j=1, string.len(word) do
          _createTile(x, y, string.sub(word, j, j), scoresTable[i].score == score)
          x = x + dim.Q50
        end
      end

      y = y + dim.Q50
    end
  end

  if score < scoresTable[10].score then
    y = y + dim.Q50

    _createTile(dim.Q50, y, tostring(score), true)

    if words and #words > 1 then
      local x = dim.Q50 * 3
      local word = words[1]
      for j=1, string.len(word) do
        _createTile(x, y, string.sub(word, j, j), true)
        x = x + dim.Q50
      end
    end
  end

--[[
  local newButton = widget.newButton({
    id = 'new',
    label = '★',
    labelColor = { default=_G.MUST_COLORS.black, over=_G.MUST_COLORS.black },
    font = _G.TILE_FONT,
    fontSize = dim.Q50,
    x = display.contentCenterX,
    y = display.contentHeight - dim.Q,
    onRelease = function()
      composer.gotoScene('Must', {effect='fade'})
    end,

    shape = 'roundedrect',
    width = dim.Q50,
    height = dim.Q50,
    cornerRadius = dim.Q / 20,
    fillColor = { default=_G.MUST_COLORS.ivory, over=_G.MUST_COLORS.ivory },
    -- strokeColor = { default=_G.MUST_COLORS.black, over=_G.MUST_COLORS.black }
  })
  sceneGroup:insert(newButton)
]]
  local newButton = _createTile(display.contentCenterX, display.contentHeight - dim.Q, '★', true)
  newButton:addEventListener('tap', function() composer.gotoScene('Must', {effect='fade'}) end)
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
    composer.removeScene('HighScores')
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
      composer.gotoScene('Must', {effect='fade'})
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
