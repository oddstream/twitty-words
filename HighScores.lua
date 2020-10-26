
-- HighScores.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local scene = composer.newScene()

local widget = require('widget')
local json = require('json')

local Tile = require 'Tile'
-- local Util = require 'Util'

local tiles = nil

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
      {score=1000, words={'SHENANIGANS'}},
      {score=950, words={'BAMBOOZLE'}},
      {score=900, words={'SERENDIPITY'}},
      {score=850, words={'BODACIOUS'}},
      {score=800, words={'VIXENS'}},
      {score=750, words={'BROUHAHA'}},
      {score=700, words={'SCRUMPTIOUS'}},
      {score=650, words={'CANOODLE'}},
      {score=600, words={'PETRICHOR'}},
      {score=550, words={'NIMCOMPOOP'}},
      {score=500, words={'EUPHORIA'}},
      {score=450, words={'GOGGLES'}},
      {score=400, words={'GOGGLE'}},
      {score=300, words={'GUBBINS'}},
      {score=350, words={'SUPINE'}},
      {score=250, words={'MALARKEY'}},
      {score=200, words={'IDYLLIC'}},
      {score=150, words={'DAINTY'}},
      {score=100, words={'GNARLY'}},
      {score=50, words={'GNOME'}},
    }
  end
end

local function saveScores()
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

--[[
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
]]

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

  local function _createTile(x, y, txt, selected)
    local grp = Tile.createGraphics(x, y, txt)
    sceneGroup:insert(grp)
    grp:scale(0.5, 0.5)
    if selected then
      grp[2]:setFillColor(unpack(_G.MUST_COLORS.gold))
    end
    table.insert(tiles, grp)

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

      table.insert(scoresTable, {score=score, words=words})

      table.sort(scoresTable, function(a,b) return a.score > b.score end) -- default comp uses <

      if score > scoresTable[#scoresTable].score then
        -- trace('writing scores')
        saveScores()
      -- else
      --   trace('worthless new score')
      end

    end
  end

  local height = _G.DIMENSIONS.toolBarHeight
  local halfHeight = height / 2

  local rect = display.newRect(sceneGroup, display.contentCenterX, halfHeight, display.contentWidth, height)
  rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  local newButton = widget.newButton({
    x = 0,
    y = halfHeight,
    onRelease = function()
      -- flyAwayTiles()
      composer.gotoScene('Must', {effect='slideLeft'})
    end,
    label = ' < NEW GAME',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'left',
    font = _G.TILE_FONT,
    fontSize = dim.halfQ,
    textOnly = true,
  })
  newButton.anchorX = 0
  sceneGroup:insert(newButton)
  -- local bannerText = 'HIGH SCORES'
  -- if event.params and event.params.banner then
  --   bannerText = event.params.banner
  -- end

  local y = dim.toolBarHeight + dim.halfQ
  -- local highScoresBanner = display.newText(sceneGroup, bannerText, display.contentCenterX, y, native.systemFontBold, 72)
  -- y = y + dim.halfQ

  -- if score then
  --   local infoText1 = string.format('SCORE %d', event.params.score)
  --   local displayText1 = display.newText(sceneGroup, infoText1, display.contentCenterX, y, native.systemFontBold, 72)
  --   displayText1:setFillColor(0,0,0)
  --   y = y + dim.halfQ
  -- end

  tiles = {}

  for i = 1, 20 do
    if scoresTable[i] then
      _createTile(dim.halfQ, y, tostring(scoresTable[i].score), scoresTable[i].score == score)

      do
        local x = dim.halfQ * 3
        local word = scoresTable[i].words[1]
        for j=1, string.len(word) do
          _createTile(x, y, string.sub(word, j, j), scoresTable[i].score == score)
          x = x + dim.halfQ
        end
      end

      y = y + dim.halfQ
    end
  end

  if score < scoresTable[20].score then
    y = y + dim.halfQ

    _createTile(dim.halfQ, y, tostring(score), true)

    if words and #words > 0 then
      local x = dim.halfQ * 3
      local word = words[1]
      for j=1, string.len(word) do
        _createTile(x, y, string.sub(word, j, j), true)
        x = x + dim.halfQ
      end
    end
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
      composer.gotoScene('Must')
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
