-- Grid (of Slots) class

local composer = require('composer')

local Slot = require 'Slot'
local Util = require 'Util'

local Grid = {
  -- prototype object
  slots = nil,    -- array of Tile objects
  width = nil,      -- number of columns
  height = nil,      -- number of rows

  undoStack = {},
  letterPool = nil,

  selectedSlots = nil,  -- table of selected slots, in order they were selected
  score = nil,
  words = nil,
  swaps = nil,

  countdownTimer = nil,  -- timer
  secondsLeft = nil,
}
Grid.__index = Grid

function Grid.new(width, height)
  local o = {}
  setmetatable(o, Grid)

  o.slots = {}
  o.width = width
  o.height = height

  o:createSlots()
  o:linkSlots()

  return o
end

function Grid:createSaveable()
  local o = {}
  o.letterPool = table.clone(self.letterPool)
  do
    local state = {}
    for _,slot in ipairs(self.slots) do
      if slot.tile then
        table.insert(state, {x=slot.x, y=slot.y, letter=slot.tile.letter})
      end
    end
    o.state = state
  end
  o.words = table.clone(self.words)
  o.swaps = self.swaps
  -- self.hints is not covered by the unconditional undo guarantee
  o.score = self.score  -- TODO could recalc this
  return o
end

function Grid:replaceWithSaved(saved)
  self:deleteTiles()

  self.letterPool = saved.letterPool
  self:createTilesFromSaved(saved.state)
  self.words = saved.words
  self.swaps = saved.swaps
  -- self.hints is not covered by the unconditional undo guarantee
  self.score = saved.score  -- TODO could recalc this

  self:updateUI()
end

function Grid:undo()
  local saved = table.remove(self.undoStack)
  if saved then
    self:replaceWithSaved(saved)
  end
end

function Grid:timer(event)
  -- event.source (Grid table)
  -- event.count
  if self.secondsLeft > 0 then
    self.secondsLeft = self.secondsLeft - 1

    if self.secondsLeft < 10 then
      Util.sound('timer')
    end
  end

  _G.statusbar:setRight(string.format('%u:%02u',
    math.floor(self.secondsLeft / 60),
    math.floor(self.secondsLeft % 60)))

    if self.secondsLeft == 0 then
    self:gameOver()
  end
end

function Grid:pauseCountdown()
  if self.countdownTimer then
    trace('pause countdownTimer')
    timer.pause(self.countdownTimer)
  end
end

function Grid:resumeCountdown()
  if self.countdownTimer then
    trace('resume countdownTimer')
    timer.resume(self.countdownTimer)
  end
end

function Grid:cancelCountdown()
  if self.countdownTimer then
    trace('cancel countdownTimer')
    timer.cancel(self.countdownTimer)
  -- the following produced runtime error, not sure why
  self.countdownTimer = nil
  end
end

function Grid:destroy()
  trace('Gird:destroy()')
end

function Grid:gameOver()

  self:cancelCountdown()

  local deductions = 0
  if type(_G.GAME_MODE) ~= 'number' then
    deductions = self:calcResidualScore()
  end

  self:deleteTiles()

  composer.gotoScene('HighScores', { params={score=self.score - deductions, words=self.words} })

  do
    local before = collectgarbage('count')
    collectgarbage('collect')
    local after = collectgarbage('count')
    print('collected', math.floor(before - after), 'KBytes, now using', math.floor(after), 'KBytes')
  end

end

function Grid:newGame()

  self:createLetterPool()

  -- create tiles
  self:createTiles()

  -- reset our variables
  self.score = 0
  self.words = {}
  self.swaps = 1
  self.hints = 3
  self.selectedSlots = {}
  self.undoStack = {}

  if self.countdownTimer then
    trace('WARNING: deleting old countdownTimer')
    timer.cancel(self.countdownTimer)
    self.countdownTimer = nil
  end

  if _G.GAME_MODE == 'timed' then
    self.secondsLeft = 60 * 4
    self.countdownTimer = timer.performWithDelay(1000, self, 0)
  end

  -- update ui
  self:updateUI()
end

function Grid:updateUI(s, score)

  -- if system.getInfo('environment') == 'simulator' then
  --   _G.statusbar:setLeft(string.format('%s(%s) %u', _G.GAME_MODE, type(_G.GAME_MODE):sub(1,1), #self.words))
  -- end

  if score and #self.selectedSlots > 0 then
    _G.statusbar:setCenter(string.format('+%u', score))
  else
    _G.statusbar:setCenter(string.format('%u', self.score))  -- or '%+d'
  end

  if type(_G.GAME_MODE) == 'number' then
    _G.statusbar:setRight(string.format('%u of %u', #self.words, _G.GAME_MODE))
  end

  _G.wordbar:setCenter(s)

  if self.swaps == 0 then
    _G.toolbar:set('swap', '⇆')
    _G.toolbar:disable('swap')
  else
    _G.toolbar:set('swap', string.format('⇆ %u', self.swaps))
    _G.toolbar:enable('swap')
  end

  if self.hints == 0 then
    _G.toolbar:set('hint', ' 💡 ')
    _G.toolbar:disable('hint')
  else
    _G.toolbar:set('hint', string.format('💡 %u', self.hints))
    _G.toolbar:enable('hint')
  end

  if #self.undoStack > 0 then
    _G.toolbar:enable('undo')
  else
    _G.toolbar:disable('undo')
  end

  if #self.words > 0 then
    _G.toolbar:enable('result')
  else
    _G.toolbar:disable('result')
  end
end

function Grid:createLetterPool()

  self.letterPool = {}

  for i=1, string.len(_G.SCRABBLE_LETTERS) do
    local letter = string.sub(_G.SCRABBLE_LETTERS, i, i)
    table.insert(self.letterPool, letter)
  end
  -- assert(#self.letterPool==100)

  -- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
  -- https://stackoverflow.com/questions/35572435/how-do-you-do-the-fisher-yates-shuffle-in-lua

  for i=#self.letterPool, 1, -1 do
    local j = math.random(i)
    self.letterPool[i], self.letterPool[j] = self.letterPool[j], self.letterPool[i]
  end

end

function Grid:sortWords()

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

  table.sort(self.words, wordScoreComp)
end

function Grid:iterator(fn)
  for _,s in ipairs(self.slots) do
    fn(s)
  end
end

function Grid:findSlot(x,y)
  for _,s in ipairs(self.slots) do
    if s.x == x and s.y == y then
      return s
    end
  end
  return nil
end

function Grid:createSlots()
  for y = 1, self.height do
    for x = 1, self.width do
      local s = Slot.new(self, x, y)
      table.insert(self.slots, s) -- push
    end
  end
end

function Grid:linkSlots()
  for _,s in ipairs(self.slots) do
    s.n = self:findSlot(s.x, s.y - 1)
    s.ne = self:findSlot(s.x + 1, s.y - 1)
    s.e = self:findSlot(s.x + 1, s.y)
    s.se = self:findSlot(s.x + 1, s.y + 1)
    s.s = self:findSlot(s.x, s.y + 1)
    s.sw = self:findSlot(s.x - 1, s.y + 1)
    s.w = self:findSlot(s.x - 1, s.y)
    s.nw = self:findSlot(s.x - 1, s.y - 1)
  end
end

function Grid:calcResidualScore()
  local score = 0
  for _,slot in ipairs(self.slots) do
    if slot.tile then
      score = score + _G.SCRABBLE_SCORES[slot.tile.letter]
    end
  end
  return score
end

function Grid:getSelectedWord()
  local word = ''
  local score = 0
  for _,slot in ipairs(self.selectedSlots) do
    local letter = slot.tile.letter
    word = word .. letter
    score = score + _G.SCRABBLE_SCORES[letter]
  end
  return word, score * word:len()
end

function Grid:createTiles()
  for _,slot in ipairs(self.slots) do
    slot:createTile()
  end
end

function Grid:createTilesFromSaved(saved)
  for _,save in ipairs(saved) do
    local slot = self:findSlot(save.x, save.y)
    slot:createTile(save.letter)
  end
end

function Grid:deleteTiles()
  for _,slot in ipairs(self.slots) do
    if slot.tile then
      slot.tile:delete()
      slot.tile = nil
    end
    -- restore position of slot in case it compacted
    slot:position()
  end
end

function Grid:countTiles()
  local count = 0
  for _,slot in ipairs(self.slots) do
    if slot.tile then
      count = count + 1
    end
  end
  return count
end

function Grid:getTiles()
  local tiles = {}
  for _,slot in ipairs(self.slots) do
    if slot.tile then
      table.insert(tiles, slot.tile)  -- push
    end
  end
  return tiles
end

function Grid:deselectAllSlots()
  for _,slot in ipairs(self.slots) do
    slot:deselect()
  end
  self.selectedSlots = {}
end

function Grid:selectSlot(slot)
  assert(slot.tile)

  local function _connected(a, b)
    for _,dir in ipairs(_G.TOUTES_DIRECTIONS) do
      if a[dir] == b then
        return true
      end
    end
    trace('not connected')
    return false
  end

  if #self.selectedSlots == 0 then
    Util.sound('select')
    table.insert(self.selectedSlots, slot)
  else
    local last = self.selectedSlots[#self.selectedSlots]
    if slot ~= last then
      if table.contains(self.selectedSlots, slot) then
        local lastButOne = self.selectedSlots[#self.selectedSlots-1]
        if slot == lastButOne then
          -- trace('backtracking')
          Util.sound('select')
          table.remove(self.selectedSlots)  -- remove last element
          last:deselect()
        end
      else
        -- selecting a new/unselected tile
        if not _connected(slot, last) then
          self:deselectAllSlots()
        else
          Util.sound('select')
          table.insert(self.selectedSlots, slot)
        end
      end
    end
  end

  self:updateUI(self:getSelectedWord())
end

--[[
function Grid:tapped(slot)
  if not table.contains(self.selectedSlots, slot) then
    table.insert(self.selectedSlots, slot)
trace('added', slot.tile.letter, '#self.selectedSlots now', #self.selectedSlots)
    if #self.selectedSlots == 2 and self.swaps > 0 then
      local t1 = self.selectedSlots[1].tile
      local t2 = self.selectedSlots[2].tile
trace('swapping', t1.letter, t2.letter)

      self:deselectAllSlots()

      self.swaps = self.swaps - 1
      _self:updateUI()
    end
  end
end
]]

function Grid:testSelection()
  if #self.selectedSlots == 2 then
    local s1 = self.selectedSlots[1]
    local s2 = self.selectedSlots[2]
    local t1 = s1.tile
    local t2 = s2.tile
    if self.swaps > 0 then
      table.insert(self.undoStack, self:createSaveable())
      if t1.letter ~= t2.letter then

        Util.sound('swap')

        s1.tile, s2.tile = s2.tile, s1.tile
        t1.slot = s2
        t1:settle()
        t2.slot = s1
        t2:settle()

        self.selectedSlots[#self.selectedSlots]:flyAwaySwaps(-1) -- this decrements swaps
      end
    else
      Util.sound('shake')
      t1:shake()
      t2:shake()
    end
    self:deselectAllSlots()
  elseif #self.selectedSlots > 2 then
    local word, score = self:getSelectedWord()
    if Util.isWordInDictionary(word) then
    -- if true then
      -- trace(score, word)

      Util.sound('found')

      table.insert(self.undoStack, self:createSaveable())
      table.insert(self.words, word)
      -- updateUI later when score has transitioned
      self:sortWords()

      do
        local n = 1
        for _,slot in ipairs(self.selectedSlots) do
          slot.tile:flyAway(n, #self.selectedSlots) -- calls Tile:delete()
          slot.tile = nil
          n = n + 1
        end
      end

      do
        local src = self.selectedSlots[#self.selectedSlots]
        src:flyAwaySwaps(1) -- this increments swaps
        src:flyAwayScore(score) -- this increments score
      end

      self.selectedSlots = {}

      self:dropColumns()
      self:compactColumns()
      if #self.letterPool > 0 then
        self:addTiles()
      end

      -- wait for tile transitions to finish (and tiles be deleted) before updating UI and checking for end of game
      timer.performWithDelay(_G.FLIGHT_TIME, function()
        self:updateUI(word, score)
        if self:countTiles() < 3 then -- will end automatically with 0, 1 or 2 tiles
          self:gameOver()
        elseif type(_G.GAME_MODE) == 'number' and #self.words == _G.GAME_MODE then
          self:gameOver()
        end
      end)
    else  -- word not in dictionary
      Util.sound('shake')
      for _,slot in ipairs(self.selectedSlots) do
        slot.tile:shake()
      end
      self:deselectAllSlots()
      self:updateUI()
    end
  end
end

function Grid:dropColumn(bottomSlot)

  -- make an array of contiguous (sharing a common border; touching) tiles
  local contigTiles = {}
  local slot = bottomSlot
  while slot do
    if slot.tile then
      table.insert(contigTiles, slot.tile) -- push
    end
    slot = slot.n
  end
  -- trace('#contigTiles', #contigTiles)

  -- copy contigous tiles to original column of slots
  -- y is kept in two places: slot.center.y and slot.tile.grp.y
  -- slot.center.y does not change; slot.tile.grp.y does

  -- length of src will be less than or equal to 'length' of dst
  assert(#contigTiles <= self.height)
  -- if #contigTiles == self.height then
  --   trace('skipping untouched column')
  --   return
  -- end

  local dst = bottomSlot

  for _,tile in ipairs(contigTiles) do

    -- assert(src.center.x==dst.center.x)
    -- trace('transitioning')
    assert(tile.grp)

    dst.tile = tile
    tile.slot = dst

    -- dst.tile.grp.y = dst.center.y
    transition.moveTo(tile.grp, {
      y = dst.center.y,
      time = _G.FLIGHT_TIME,
      transition = easing.outQuart,
    })

    dst = dst.n
  end

  -- blank out any remaining slots in the original column
  -- tile.grp may be cloned, in two slots at once
  -- so don't mess with it

  while dst do
    if dst.tile then
      dst.tile = nil
    end
    dst = dst.n
  end

end

function Grid:dropColumns()
  local slot = self:findSlot(1, self.height)
  while slot do
    self:dropColumn(slot)
    slot = slot.e
  end
end

function Grid:slideColumn(col, dir)
  -- trace('slide column', col, dir)
  assert(dir=='e' or dir=='w')
  local src = self:findSlot(col, 1)
  while src do
    if src.tile then
      local dst = src[dir]
      assert(not dst.tile)

      transition.moveTo(src.tile.grp, {
        x = dst.center.x,
        time = _G.FLIGHT_TIME,
        transition = easing.outQuart,
      })
      -- src.tile.grp.x = dst.center.x

      dst.tile = src.tile
      dst.tile.slot = dst

      src.tile = nil
    end
    src = src.s
  end
end

function Grid:compactColumns()
  local dim = _G.DIMENSIONS

  local function _isColumnEmpty(col)
    local slot = self:findSlot(col, 1)
    while slot do
      if slot.tile then return false end
      slot = slot.s
    end
    return true
  end

  -- local oldCols = 0
  -- for col=1, self.width do
  --   if not _isColumnEmpty(col) then
  --     oldCols = oldCols + 1
  --   end
  -- end

  local moved
  repeat
    moved = false
    for col=1, self.width-1 do
      if _isColumnEmpty(col) and not _isColumnEmpty(col+1) then
        self:slideColumn(col+1, 'w')
        moved = true
      end
    end
  until not moved

  local newCols = 0
  for col=1, self.width do
    if not _isColumnEmpty(col) then
      newCols = newCols + 1
    end
  end

  local widthCols = dim.Q * newCols
  local newMargin = (display.actualContentWidth / 2) - (widthCols / 2)

  for _,slot in ipairs(self.slots) do
    slot.center.x = (slot.x * dim.Q) - dim.Q + dim.halfQ  -- copied from Slot.new()
    slot.center.x = slot.center.x + newMargin
    if slot.tile then
      transition.moveTo(slot.tile.grp, {
        x = slot.center.x,
        time = _G.FLIGHT_TIME,
        transition = easing.outQuart,
      })
    end
  end
end

--[[
function Grid:shuffle1(tiles)

  local function _reslot(slot)
    slot.tile.slot = slot
    transition.moveTo(slot.tile.grp, {
      x = slot.center.x,
      y = slot.center.y,
      time = _G.FLIGHT_TIME,
      transition = easing.outQuart,
    })
  end

  while #tiles > 1 do
    local slot1 = table.remove(tiles).slot
    local slot2 = table.remove(tiles).slot
    -- swap the tiles (with transition)
    slot1.tile, slot2.tile = slot2.tile, slot1.tile
    _reslot(slot1)
    _reslot(slot2)
  end
  assert(#tiles==0 or #tiles==1)
  -- if #tiles == 1, that's okay; one didn't have a partner to swap with, so stays put
end
]]

function Grid:shuffle2(tiles)

  for y = self.height, 1, -1 do
    for x = 1, self.width do
      local dst = self:findSlot(x,y)
      dst:position()  -- restore pre-compacted position
      local tile = table.remove(tiles)
      if tile then
        dst.tile = tile
        tile.slot = dst
        transition.moveTo(tile.grp, {
          x = dst.center.x,
          y = dst.center.y,
          time = _G.FLIGHT_TIME,
          transition = easing.outQuart,
        })
      else
        dst.tile = nil
      end
    end
  end

end

function Grid:shuffle()

  if self.swaps == 0 then
    return
  end

  local tiles = self:getTiles()
  if #tiles < 3 then
    return
  end

  self:deselectAllSlots()

  table.insert(self.undoStack, self:createSaveable())

  Util.sound('shuffle')

  -- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
  -- https://stackoverflow.com/questions/35572435/how-do-you-do-the-fisher-yates-shuffle-in-lua
  for i=#tiles, 1, -1 do
    local j = math.random(i)
    tiles[i], tiles[j] = tiles[j], tiles[i]
  end

  -- if self:countTiles() == self.width * self.height then
  --   self:shuffle1(tiles)
  -- else
    self:shuffle2(tiles)
  -- end

  self.swaps = self.swaps - 1
  self:updateUI()

end

function Grid:addTiles()

  local function _tilesInColumn(slot)
    local count = 0
    while slot do
      if slot.tile then count = count + 1 end
      slot = slot.s
    end
    return count
  end

  local tilesAdded = false
  local column = self:findSlot(1,1)
  while column and #self.letterPool > 0 do
    local count = _tilesInColumn(column)
    if count > 0 and count < self.height then
      local slot = column
      while slot and slot.tile == nil and #self.letterPool > 0 do
        if slot:createTile() then
          slot.tile.grp.y = -(display.contentHeight / 2)  -- fall from a great height, to create slight delay
          slot.tile:settle()
          tilesAdded = true
        end
        slot = slot.s
      end
    end
    column = column.e
  end

  if tilesAdded then
    self:dropColumns()
  end

end

function Grid:DFS(path, word)

  local slot = path[#path]

  for _,dir in ipairs(_G.TOUTES_DIRECTIONS) do

    local slot2 = slot[dir]
    if slot2 and slot2.tile and (not table.contains(path, slot2)) then
      local w = word .. slot2.tile.letter
      -- if string.len(w) < 10 then
        if Util.isWordPrefixInDict(w) then
          table.insert(path, slot2)
          self:DFS(path, w)
        end
      -- end
    else  -- end of the path
      if string.len(word) > 2 then
        if not table.contains(self.foundWords, word) then
          if Util.isWordInDict(word) then
            table.insert(self.foundWords, word)
            -- assert(#path==string.len(word))
            self.foundPaths[word] = table.clone(path)
            -- assert(#self.foundPaths[word]==string.len(word))
          end
        end
      end
    end
  end

  table.remove(path)

end

function Grid:hint()

  local function _calcScore(s)
    local score = 0
    for i=1, string.len(s) do
      score = score + _G.SCRABBLE_SCORES[string.sub(s, i, i)]
    end
    return score * string.len(s)
  end

  local function _maxWord()
    local maxScore = 0
    local maxWord = ''
    for _,word in ipairs(self.foundWords) do
      local score = _calcScore(word)
      if score > maxScore then
        maxScore = score
        maxWord = word
      end
    end
    return maxWord, maxScore
  end

  if self.hints < 1 then
    Util.sound('failure')
    return
  end

  local function _body(event)
    local source = event.source
    local timeStart = system.getTimer()

    for _,slot in ipairs(self.slots) do
      if slot.tile then
        slot.tile:mark()

        coroutine.yield() -- yield to the timer, so UI can update; adds about 1.5 seconds

        self:DFS({slot}, slot.tile.letter)

        -- showing the word as we go adds 3 seconds
        -- local maxWord, _ = _maxWord()
        -- _G.wordbar:setCenter(maxWord)

        slot.tile:unmark()

        -- second call to coroutine.yield adds 2-ish seconds
        -- coroutine.yield() -- yield to the timer, so UI can update
      end
    end

    timer.cancel(source)
    local timeStop = system.getTimer()

    if #self.foundWords > 0 then
      Util.sound('found')

      local maxWord, maxScore = _maxWord()

      trace(#self.foundWords, 'found in', (timeStop - timeStart) / 1000, 'seconds, best', maxWord, 'score', maxScore)

      local path = self.foundPaths[maxWord]
      -- assert(path)
      -- assert(#path==string.len(maxWord))
      for _,slot in ipairs(self.slots) do
        if table.contains(path, slot) then
          if slot.tile then -- may have timed out and been deleted
            slot.tile:select()
          else
            break
          end
        end
      end

      -- uncomment the following if you want to do anything with selecetd slots
      -- self.selectedSlots = table.clone(path)

      if system.getInfo('environment') ~= 'simulator' then
        self.hints = self.hints - 1
      end

      self:updateUI(maxWord)
    else
      Util.sound('failure')
      self:updateUI()
    end
  end

  self:deselectAllSlots()
  self.foundWords = {}
  self.foundPaths = {}

  -- _G.DICT_TRUE = {}
  -- _G.DICT_FALSE = {}
  _G.DICT_PREFIX_TRUE = {}
  _G.DICT_PREFIX_FALSE = {}

  -- https://coronalabs.com/blog/2015/02/10/tutorial-using-coroutines-in-corona/

  timer.performWithDelay(0, coroutine.wrap(_body), 0)

--[[
  local co = coroutine.create(function()

    for _,slot in ipairs(self.slots) do
      if slot.tile then
        self:DFS(slot, {slot}, slot.tile.letter)
        coroutine.yield()
      end
    end

  end)

  while coroutine.status(co) == 'suspended' do

    -- local maxWord, maxScore = _maxWord()

    -- trace('MAX WORD', maxWord, 'SCORE', maxScore)

    -- _G.wordbar:setCenter(tostring(#self.foundWords))
    -- timer.performWithDelay(30, function() coroutine.resume(co) end)
    coroutine.resume(co)
  end

  -- trace(coroutine.status(co))
]]

end

function Grid:showFoundWords()
  Util.sound('ui')
  self:pauseCountdown()
  composer.showOverlay('FoundWords', {effect='slideRight'})
end

return Grid
