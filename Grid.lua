-- Grid (of Slots) class

local composer = require('composer')

local const = require 'constants'
local globalData = require 'globalData'

local Bubble = require 'Bubble'
local Slot = require 'Slot'
local Util = require 'Util'

local Grid = {
  -- prototype object
  slots = nil,    -- array of Tile objects
  width = nil,      -- number of columns
  height = nil,      -- number of rows

  letterPool = nil,

  humanFoundWords = nil,
  robotFoundWords = nil,
  selectedSlots = nil,  -- table of selected slots, in order they were selected
  humanScore = nil,
  robotScore = nil,

  -- humanCanFinish = true,

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
  o.humanFoundWords = table.clone(self.humanFoundWords)
  o.robotFoundWords = table.clone(self.robotFoundWords)
  -- self.hints is not covered by the unconditional undo guarantee
  o.humanScore = self.humanScore  -- could recalc this
  o.robotScore = self.robotScore  -- could recalc this
  o.swaps = self.swaps
  o.swapLoss = self.swapLoss
  -- o.selectedSlots = table.clone(self.selectedSlots)
  return o
end

function Grid:replaceWithSaved(saved)
  self:deleteTiles()

  self.letterPool = saved.letterPool
  self:createTilesFromSaved(saved.state)
  self.humanFoundWords = saved.humanFoundWords
  self.robotFoundWords = saved.robotFoundWords
  -- self.hints is not covered by the unconditional undo guarantee
  self.humanScore = saved.humanScore  -- could recalc this
  self.robotScore = saved.robotScore  -- could recalc this
  self.swaps = saved.swaps
  self.swapLoss = saved.swapLoss
  -- self.selectedSlots = saved.selectedSlots
  self.selectedSlots = {}

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

  globalData.statusbar:setRight(string.format('%u:%02u',
    math.floor(self.secondsLeft / 60),
    math.floor(self.secondsLeft % 60)))

  if self.secondsLeft == 0 then
    self:pauseCountdown() -- stop multiple calls here
    Util.showAlert('GAME OVER', 'Time\'s up!',
    {'OK'},
    function() self:gameOver() end)
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
  if const.VARIANT[globalData.mode].deductions then
    deductions = self:calcResidualScore()
  end

  self:deleteTiles()

  Util.mergeIntoHintDictionary(self.humanFoundWords)

  if const.VARIANT[globalData.mode].robot then
    composer.gotoScene('RobotEnd', { effect='slideLeft', params={humanScore=self.humanScore, humanFoundWords=self.humanFoundWords, robotScore=self.robotScore, robotFoundWords=self.robotFoundWords, swapLoss=self.swapLoss} })
  else
    composer.gotoScene('HighScores', { effect='slideLeft', params={score=self.humanScore - deductions, words=self.humanFoundWords, swapLoss=self.swapLoss} })
  end

end

function Grid:cancelGame()

  self:cancelCountdown()

  self:deleteTiles()

end

function Grid:newGame()

  self.letterPool = {}
  self:fillLetterPool()

  -- create tiles
  self:createTiles()

  -- reset our variables
  self.humanScore = 0
  self.robotScore = 0
  self.humanFoundWords = {}
  self.robotFoundWords = {}
  self.swaps = 0  -- number of letter swaps human has made this turn
  self.swapLoss = 0 -- points lost to swaps in this game
  self.hints = 1  -- number of hints human has left to use this game
  self.selectedSlots = {}
  self.undoStack = {}

  -- maybe start a countdown timer
  if self.countdownTimer then
    trace('WARNING: deleting old countdownTimer')
    timer.cancel(self.countdownTimer)
    self.countdownTimer = nil
  end

  if const.VARIANT[globalData.mode].timer ~= nil then
    self.secondsLeft = const.VARIANT[globalData.mode].timer
  else
    self.secondsLeft = 0
  end
  if self.secondsLeft > 0 then
    self.countdownTimer = timer.performWithDelay(1000, self, 0)
  end

  Util.resetDictionaries()

  globalData.toolbar:enable('shuffle', true)

  -- update ui
  Util.sound('found') -- make a happy sound
  self:updateUI()

  do
    local before = collectgarbage('count')
    collectgarbage('collect')
    local after = collectgarbage('count')
    print('collected', math.floor(before - after), 'KBytes, now using', math.floor(after), 'KBytes')
  end

end

function Grid:afterMove(word)

  -- trace(self:countTiles(), 'tiles left')

  if not word then self:deselectAllSlots() end

  self:updateUI(word)

  if self:countTiles() < 3 then -- will end automatically with 0, 1 or 2 tiles

    Util.showAlert('GAME OVER', 'Too few tiles left',
      {'OK'},
      function() self:gameOver() end)
--[[
  elseif type(globalData.mode) == 'number' and #self.humanFoundWords == globalData.mode then

    Util.showAlert('GAME OVER', 'You found ' .. tostring(#self.humanFoundWords) .. ' words',
      {'OK'},
      function() self:gameOver() end)
]]
  elseif const.VARIANT[globalData.mode].scoreTarget ~= nil then

    local scoreTarget = const.VARIANT[globalData.mode].scoreTarget
    if self.humanScore >= scoreTarget or self.robotScore >= scoreTarget then
      Util.showAlert('GAME OVER', 'Score target reached',
        {'OK'},
        function() self:gameOver() end)
    end

  elseif globalData.mode == 'FILLUP' then
    if self:countTiles() == self.width * self.height then
      Util.showAlert('GAME OVER', 'The grid is full of tiles',
        {'OK'},
        function() self:gameOver() end)
    end
  end

end

function Grid:updateUI(word)

  local function _countFoundLetters()
    local count = 0
    for _,w in ipairs(self.humanFoundWords) do
      count = count + string.len(w)
    end
    for _,w in ipairs(self.robotFoundWords) do
      count = count + string.len(w)
    end
    return count
  end

  if const.VARIANT[globalData.mode].robot then
    globalData.statusbar:setCenter(string.format('%d : %d', self.humanScore, self.robotScore))  -- or '%+d'
  else
    globalData.statusbar:setCenter(string.format('SCORE %d', self.humanScore))  -- or '%+d'
  end

  if const.VARIANT[globalData.mode].showPercent then
    --string.len(_G.SCRABBLE_LETTERS) == 100, so ...
    globalData.statusbar:setRight(string.format('%u%%', _countFoundLetters()))
--[[
  elseif type(globalData.mode) == 'number' then
    globalData.statusbar:setRight(string.format('%u of %u', #self.humanFoundWords, globalData.mode))
    -- time remaining is set directly from Grid:timer()
    -- nothing is currently set in ROBOTO mode
]]
  elseif const.VARIANT[globalData.mode].showFree then
    globalData.statusbar:setRight(string.format('FREE %u', self.width * self.height - self:countTiles()))
  end

  if word == nil and #self.selectedSlots > 0 then
    word = self:getSelectedWord()
  end

  globalData.wordbar:setCenter(word)

  globalData.toolbar:enable('hint', self.hints > 0)
  globalData.toolbar:enable('undo', #self.undoStack > 0)
  globalData.toolbar:enable('result', #self.humanFoundWords > 0)

end

function Grid:fillLetterPool()

  trace('Filling letter pool')

  for i=1, string.len(const.SCRABBLE_LETTERS) do
    local letter = string.sub(const.SCRABBLE_LETTERS, i, i)
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

function Grid:sortWords(foundWords)

  local function wordScoreComp(a, b)
    local function calcScore(s)
      local score = 0
      for i=1, string.len(s) do
        score = score + const.SCRABBLE_SCORES[string.sub(s, i, i)]
      end
      return score * string.len(s)
    end
    return calcScore(a) > calcScore(b)
  end

  table.sort(foundWords, wordScoreComp)
end

--[[
function Grid:iterator(fn)
  for _,s in ipairs(self.slots) do
    fn(s)
  end
end
]]

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
      score = score + const.SCRABBLE_SCORES[slot.tile.letter]
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
    score = score + const.SCRABBLE_SCORES[letter]
  end
  return word, score * word:len()
end

function Grid:createTiles()
  if globalData.mode == 'FILLUP' then
    for y = self.height-2, self.height do
      for x = 1, self.width do
        local slot = self:findSlot(x,y)
        slot:createTile()
      end
    end
  else
    for _,slot in ipairs(self.slots) do
      slot:createTile()
    end
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

  local function _connected(a, b)
    for _,dir in ipairs(const.TOUTES_DIRECTIONS) do
      if a[dir] == b then
        return true
      end
    end
    -- trace('not connected')
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
          Util.sound('timer')  -- TODO need deselect sound
          table.remove(self.selectedSlots)  -- remove last element
          last:deselect()
        end
      else
        -- selecting a new/unselected tile
        if not _connected(slot, last) then
          Util.sound('failure')
          self:deselectAllSlots()
        else
          Util.sound('select')
          table.insert(self.selectedSlots, slot)
        end
      end
    end

    -- pearl from the mudbank; selection may have backtracked so selectedSlots may have shrunk

    do
      local dim = globalData.dim

      if #self.selectedSlots == 1 then
        local src = self.selectedSlots[1]
        assert(src)
        local score = const.SCRABBLE_SCORES[src.tile.letter]
        Bubble.new(src.center.x, src.center.y - dim.halfQ, string.format('%d', score)):fadeOut()
      elseif #self.selectedSlots == 2 then
        local t1 = self.selectedSlots[1].tile
        local t2 = self.selectedSlots[2].tile
        local score = (const.SCRABBLE_SCORES[t1.letter] + const.SCRABBLE_SCORES[t2.letter]) * (self.swaps + 1)
        local src = self.selectedSlots[#self.selectedSlots]
        assert(src)
        Bubble.new(src.center.x, src.center.y - dim.halfQ, string.format('-%d', score)):fadeOut()
      elseif #self.selectedSlots > 2 then
        local _, score = self:getSelectedWord()
        local src = self.selectedSlots[#self.selectedSlots]
        assert(src)
        Bubble.new(src.center.x, src.center.y - dim.halfQ, string.format('%+d', score)):fadeOut()
      end
    end

  end

  self:updateUI(self:getSelectedWord())
end

function Grid:testSelection()

  local dim = globalData.dim

  if #self.selectedSlots == 2 then

    local s1 = self.selectedSlots[1]
    local s2 = self.selectedSlots[2]
    local t1 = s1.tile
    local t2 = s2.tile

    if t1.letter ~= t2.letter then
      table.insert(self.undoStack, self:createSaveable())

      Util.sound('swap')

      s1.tile, s2.tile = s2.tile, s1.tile

      t1.slot = s2
      t1:settle()

      t2.slot = s1
      t2:settle()

      self.swaps = self.swaps + 1

      do
        local score = (const.SCRABBLE_SCORES[t1.letter] + const.SCRABBLE_SCORES[t2.letter]) * self.swaps
        Bubble.new(s2.center.x, s2.center.y, string.format('-%d', score)):flyTo(dim.statusbarX, dim.statusbarY)
        self.humanScore = self.humanScore - score
        self.swapLoss = self.swapLoss + score
      end

    end

    self:updateUI()  -- not really a move, was it?

  elseif #self.selectedSlots > 2 then

    local word, score = self:getSelectedWord()

    if Util.isWordInDictionary(word) then
    -- if true then
      -- trace(score, word)

      Util.sound('found')

      table.insert(self.undoStack, self:createSaveable())
      table.insert(self.humanFoundWords, word)
      self:sortWords(self.humanFoundWords)

      self:flyAwaySelectedSlots(score)
      self.humanScore = self.humanScore + score

      self:dropColumns()
      self:compactColumns()

      if globalData.mode == 'FILLUP' then
        self:shuffle('FILLUP')
        self:addRowOfTiles()
      else
        if #self.letterPool > 0 then
          self:addTiles()
        end
      end

      -- the human had their move, now ...
      if const.VARIANT[globalData.mode].robot then
        self:updateUI(word)
        timer.performWithDelay(2000, function()
          self:robot()
        end)
      else
        self:afterMove(word)  -- update UI and check end of game
      end

      self.swaps = 0  -- number of letter swaps human has made this turn
      globalData.toolbar:enable('shuffle', true)

    else  -- word not in dictionary

      Util.sound('shake')
      for _,slot in ipairs(self.selectedSlots) do
        slot.tile:shake()
      end

      self:updateUI()  -- not really a move, was it?

    end -- isWordInDictionary()

  end -- #self.selectedSlots > 2
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
  -- y is kept in two places: slot.center.y and slot.tile.iv.grp.y
  -- slot.center.y does not change; slot.tile.iv.grp.y does

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
    assert(tile.iv)

    dst.tile = tile
    tile.slot = dst

    tile:settle()

    dst = dst.n
  end

  -- blank out any remaining slots in the original column
  -- tile.iv.grp may be cloned, in two slots at once
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
  -- assert(dir=='e' or dir=='w')
  local src = self:findSlot(col, 1)
  while src do
    if src.tile then
      local dst = src[dir]
      assert(not dst.tile)

      dst.tile = src.tile
      dst.tile.slot = dst

      dst.tile:settle()

      src.tile = nil
    end
    src = src.s
  end
end

function Grid:compactColumns()
  local dim = globalData.dim

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
      slot.tile:settle()
    end
  end
end

function Grid:shuffle2(tiles)

  for y = self.height, 1, -1 do
    for x = 1, self.width do
      local dst = self:findSlot(x,y)
      dst:position()  -- restore pre-compacted position
      local tile = table.remove(tiles)
      if tile then
        dst.tile = tile
        tile.slot = dst
        dst.tile:settle()
      else
        dst.tile = nil
      end
    end
  end

end

function Grid:shuffle(who)

  who = who or 'human'

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

  Util.resetDictionaries()

  self:updateUI()  --- not really a move, was it?

  if who == 'human' then
    globalData.toolbar:enable('shuffle', false)
  end

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
          slot.tile:elevate()
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

function Grid:addRowOfTiles()

  local function _tilesInColumn(slot)
    local count = 0
    while slot do
      if slot.tile then count = count + 1 end
      slot = slot.s
    end
    return count
  end

  if #self.letterPool < self.width then
    self:fillLetterPool()
  end

  local tilesAdded = false
  local column = self:findSlot(1,1)
  while column do
    if _tilesInColumn(column) < self.height then
      local slot = column
      if slot and slot.tile == nil then
        if slot:createTile() then
          slot.tile:elevate()
          slot.tile:settle()
          tilesAdded = true
        end
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

  for _,dir in ipairs(const.TOUTES_DIRECTIONS) do

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
        if not table.contains(self.hintWords, word) then
          if Util.isWordInDict(word) then
            table.insert(self.hintWords, word)
            -- assert(#path==string.len(word))
            self.hintPaths[word] = table.clone(path)
            -- assert(#self.hintPaths[word]==string.len(word))
          end
        end
      end
    end
  end

  table.remove(path)

end

function Grid:hint(who)

  who = who or 'HUMAN'

  local function _calcScore(s)
    local score = 0
    for i=1, string.len(s) do
      score = score + const.SCRABBLE_SCORES[string.sub(s, i, i)]
    end
    return score * string.len(s)
  end

  local function _maxWord()
    local maxScore = 0
    local maxWord = ''
    for _,word in ipairs(self.hintWords) do
      local score = _calcScore(word)
      if score > maxScore then
        maxScore = score
        maxWord = word
      end
    end
    return maxWord, maxScore
  end

  if who == 'HUMAN' and self.hints < 1 then
    -- shouldn't happen because hints tappy will be disabled
    Util.sound('failure')
    return
  end

  local function _body(event)
    local source = event.source
    local timeStart = system.getTimer()

    for _,slot in ipairs(self.slots) do
      -- to speed things up, don't start a search with a wildcard tile
      if slot.tile and slot.tile.letter ~= ' ' then
        Util.sound('select')
        slot.tile:select(who)

        coroutine.yield() -- yield to the timer, so UI can update; adds about 1.5 seconds

        -- also, the timer may have finished during the yield and deleted the scene/tiles

        if slot.tile then
          self:DFS({slot}, slot.tile.letter)

        -- showing the word as we go adds 3 seconds
        -- local maxWord, _ = _maxWord()
        -- globalData.wordbar:setCenter(maxWord)

          slot.tile:deselect()
        end

        -- second call to coroutine.yield adds 2-ish seconds
        -- coroutine.yield() -- yield to the timer, so UI can update
      end
    end

    timer.cancel(source)
    local timeStop = system.getTimer()

    -- don't allow the (sneaky) human to finish (when they are ahead)
    -- if globalData.mode == 'ROBOTO' and who == 'ROBOTO' then
    --   self.humanCanFinish = #self.hintWords == 0
    -- else
    --   self.humanCanFinish = true
    -- end

    if #self.hintWords > 0 then

      local maxWord, maxScore = _maxWord()

      trace(#self.hintWords, 'found in', (timeStop - timeStart) / 1000, 'seconds, best', maxWord, 'score', maxScore)

      local path = self.hintPaths[maxWord]
      -- assert(path)
      -- assert(#path==string.len(maxWord))
      for _,slot in ipairs(self.slots) do
        if table.contains(path, slot) then
          if slot.tile then -- may have timed out and been deleted
            slot.tile:select(who)
          else
            break
          end
        end
      end

      -- do
      --   local dim = globalData.dim
      --   local src = path[#path]
      --   local b = Bubble.new(src.center.x, src.center.y - dim.halfQ, string.format('%+d', maxScore))
      --   b:fadeOut()
      -- end

      Util.sound('found')

      self.selectedSlots = table.clone(path)

      if who == 'ROBOTO' then
        self:_postRobot(maxWord, maxScore)
        -- the game can end after robot's move (no human's move)
        self:afterMove(maxWord) -- update UI and check for end of game
      else
        -- local dim = globalData.dim
        -- local tax = math.floor(self.humanScore * 0.1)
        -- if tax > 0 then
        --   local b = Bubble.new(globalData.toolbar.hint.grp.x, globalData.toolbar.hint.grp.y, string.format('%+d', -tax))
        --   b:flyTo(dim.statusbarX, dim.statusbarY)
        --   self.humanScore = self.humanScore - tax
        -- end
        if system.getInfo('environment') ~= 'simulator' then
          self.hints = self.hints - 1
        end
        self:updateUI(maxWord)
      end

    else  -- no hint words found
      Util.sound('failure')
      self:updateUI()  -- not really a move, was it?
    end

  end

  self:deselectAllSlots()
  self.hintWords = {}
  self.hintPaths = {}

  -- https://coronalabs.com/blog/2015/02/10/tutorial-using-coroutines-in-corona/

  timer.performWithDelay(0, coroutine.wrap(_body), 0)

end

function Grid:robot()

  if self:countTiles() < self.width * self.height then
    self:shuffle('ROBOTO')
  end

  self:hint('ROBOTO')  -- this ends in it's own time ...
  -- ... so don't put any code here
end

function Grid:flyAwaySelectedSlots(score)

  local n = 1
  for _,slot in ipairs(self.selectedSlots) do
    slot.tile:flyAway(n, #self.selectedSlots) -- calls Tile:delete()
    slot.tile = nil
    n = n + 1
  end

  do
    local dim = globalData.dim
    local src = self.selectedSlots[#self.selectedSlots]
    local b = Bubble.new(src.center.x, src.center.y, string.format('%+d', score))
    b:flyTo(dim.statusbarX, dim.statusbarY)
  end

  self.selectedSlots = {}

end

function Grid:_postRobot(word, score)

  -- trace('robot post hint #selected slots', #self.selectedSlots)

  -- don't create an undoable save point here
  -- table.insert(self.undoStack, self:createSaveable())

  self:flyAwaySelectedSlots(score)
  self.robotScore = self.robotScore + score

  table.insert(self.robotFoundWords, word)
  self:sortWords(self.robotFoundWords)

  self:dropColumns()
  self:compactColumns()
  if #self.letterPool > 0 then
    self:addTiles()
  end

end

function Grid:showFoundWords()
  Util.sound('ui')
  self:pauseCountdown()
  composer.showOverlay('FoundWords', {effect='fromLeft'})
end

function Grid:suspendTouch()
  for _,slot in ipairs(self.slots) do
    if slot.tile then
      slot.tile:removeTouchListener()
    end
  end
end

function Grid:resumeTouch()
  for _,slot in ipairs(self.slots) do
    if slot.tile then
      slot.tile:addTouchListener()
    end
  end
end

return Grid
