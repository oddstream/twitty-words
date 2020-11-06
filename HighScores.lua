
-- HighScores.lua
-- https://docs.coronalabs.com/guide/programming/06/index.html

local composer = require('composer')
local scene = composer.newScene()

local widget = require('widget')
local json = require('json')

local Tile = require 'Tile'
local Util = require 'Util'

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

  trace('HighScores scene:create')
  Util.setBackground(sceneGroup)
  sceneGroup:addEventListener('touch', backTouch)

  -- local backHeight = (20 * dim.halfQ) + display.actualContentHeight
  -- need a background rect for the touch to work when touching the, er, background (otherwise can only touch/vscroll tiles)
  -- local rectBackground = display.newRect(backGroup, display.actualContentWidth / 2, display.actualContentHeight / 2, display.actualContentWidth, backHeight)
  -- rectBackground:setFillColor(unpack(_G.MUST_COLORS.baize))

  -- a rect for the results tool bar
  local rectToolbar = display.newRect(sceneGroup, dim.resultsbarX, dim.resultsbarY, dim.resultsbarWidth, dim.resultsbarHeight)
  rectToolbar:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  local newButton = widget.newButton({
    x = dim.halfQ,
    y = dim.resultsbarY,
    onRelease = function()
      composer.removeScene('HighScores')
      composer.gotoScene('Must', {effect='slideLeft'})
    end,
    label = '< NEW GAME',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'left',
    font = _G.TILE_FONT,
    fontSize = dim.resultsbarHeight / 2,
    textOnly = true,
  })
  newButton.anchorX = 0
  sceneGroup:insert(newButton)

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

    local function _createTile(x, y, txt, selected)
      local grp = Tile.createGraphics(x, y, txt)
      sceneGroup:insert(grp)
      grp:scale(0.5, 0.5)
      if selected then
        grp[2]:setFillColor(unpack(_G.MUST_COLORS.moccasin))
      end
      return grp
    end

    local function _showScoreAndWord(thisScore, thisWord, yPos, hilite)
      _createTile(dim.halfQ, yPos, tostring(thisScore), hilite)
      local x = dim.marginX + (dim.halfQ * 3)
      for j=1, string.len(thisWord) do
        _createTile(x, yPos, string.sub(thisWord, j, j), hilite)
        x = x + dim.halfQ
      end
    end

    local y = dim.resultsbarHeight + dim.halfQ

    for i = 1, 20 do
      if scoresTable[i] then
        -- show the highest scoring word, which has been sorted (when inserted) to the front
        _showScoreAndWord(scoresTable[i].score, scoresTable[i].words[1], y, scoresTable[i].score == score)
        y = y + dim.halfQ
      end
    end

    -- show the user's pathetic effort if it's not in the top 20
    if score < scoresTable[20].score and #words > 0 then
      y = y + dim.halfQ
      _showScoreAndWord(score, words[1], y, true)
    else
      Util.sound('complete')
    end

    elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen
    -- Runtime:addEventListener('key', scene)
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  trace('HighScores scene:hide', phase)

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    -- assert(Runtime:removeEventListener('key', scene))
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  trace('HighScores scene:destroy')
end

-- function scene:key(event)
--   local phase = event.phase
--   if phase == 'up' then
--     if event.keyName == 'back' or event.keyName == 'deleteBack' then
--       composer.gotoScene('Must')
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
