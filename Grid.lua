-- Grid (of Slots) class

local composer = require('composer')

local Slot = require 'Slot'

local Grid = {
  -- prototype object
  slots = nil,    -- array of Tile objects
  width = nil,      -- number of columns
  height = nil,      -- number of rows

  selectedSlots = nil,  -- table of selected slots, in order they were selected
  score = nil,
  words = nil,
  swaps = nil,
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

function Grid:destroy()
  trace('Gird:destroy()')
end

function Grid:gameOver()
  local deductions = self:calcResidualScore()

  -- delete all tiles
  for _,slot in ipairs(self.slots) do
    if slot.tile then
      slot.tile:delete()
      slot.tile = nil
    end
    -- restore position of slot in case it compacted
    slot:position()
  end

  -- run the garbage collector
  do
    local last_using = composer.getVariable('last_using')
    if not last_using then
      last_using = 0
    end
    local before = collectgarbage('count')
    collectgarbage('collect')
    local after = collectgarbage('count')
    print('collected', math.floor(before - after), 'KBytes, using', math.floor(after), 'KBytes', 'leaked', after-last_using)
    composer.setVariable('last_using', after)
  end

  composer.gotoScene('HighScores', { params={score=self.score - deductions, words=self.words} })
end

function Grid:newGame()

  -- create tiles
  self:createTiles()

  -- reset our variables
  self.score = 0
  self.words = {}
  self.swaps = 1
  self.selectedSlots = {}

  -- update ui
  self:updateUI()
end

function Grid:updateUI()
  _G.toolBar:setLeft(string.format('⇆ %s', self.swaps))
  _G.toolBar:setRight(string.format('%+d', self.score - self:calcResidualScore()))
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

local function isWordInDictionary(word)
  local first,_ = string.find(_G.DICTIONARY, '[^%u]' .. word .. '[^%u]')
  return first ~= nil
  -- return true
end

function Grid:createTiles()
  self:iterator(function(slot)
    slot:createTile()
  end)
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
  self:iterator(function(slot)
    slot:deselect()
  end)
  self.selectedSlots = {}
  _G.toolBar:setCenter(nil)
end

function Grid:selectSlot(slot)
  assert(slot.tile)

  local function _connected(a, b)
    for _,dir in ipairs({'n','ne','e','se','s','sw','w','nw'}) do
      if a[dir] == b then
        return true
      end
    end
    trace('not connected')
    return false
  end

  local function _insert()
    table.insert(self.selectedSlots, slot)
    local word, _ = self:getSelectedWord()
    _G.toolBar:setCenter(word)
  end

  -- TODO check slot is the previous but one slot; if so, deselect last selected slot (user is backtracking)

  if #self.selectedSlots == 0 then
    _insert()
  else
    local last = self.selectedSlots[#self.selectedSlots]
    if slot ~= last then
      if table.contains(self.selectedSlots, slot) then
        local lastButOne = self.selectedSlots[#self.selectedSlots-1]
        if slot == lastButOne then
          trace('backtracking')
          table.remove(self.selectedSlots)  -- remove last element
          last:deselect()
          local word, _ = self:getSelectedWord()
          _G.toolBar:setCenter(word)
        end
      else
        -- selecting a new/unselected tile
        if not _connected(slot, last) then
          self:deselectAllSlots()
        else
          _insert()
        end
      end
    end
  end
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
      t1.letter, t2.letter = t2.letter, t1.letter
      t1:refreshLetter()
      t2:refreshLetter()

      self:deselectAllSlots()

      self.swaps = self.swaps - 1
      _G.toolBar:setLeft(string.format('⇆ %s', self.swaps))
      _G.toolBar:setCenter(string.format('%s ⇆ %s', t1.letter, t2.letter))
    end
  end
end
]]
function Grid:testSelection()
  if #self.selectedSlots == 2 then
    local t1 = self.selectedSlots[1].tile
    local t2 = self.selectedSlots[2].tile
    if self.swaps > 0 then
      if t1.letter ~= t2.letter then
        t1.letter, t2.letter = t2.letter, t1.letter
        t1:refreshLetter()
        t2:refreshLetter()

        self.swaps = self.swaps - 1
        _G.toolBar:setLeft(string.format('⇆ %s', self.swaps))
        _G.toolBar:setCenter(string.format('%s ⇆ %s', t1.letter, t2.letter))
      end
    else
      t1:shake()
      t2:shake()
    end
    self:deselectAllSlots()
  elseif #self.selectedSlots > 2 then
    local word, score = self:getSelectedWord()
    if isWordInDictionary(word) then
    -- if true then
      trace(score, word)
      table.insert(self.words, word)
      self:sortWords()

      do
        local n = 1
        for _,slot in ipairs(self.selectedSlots) do
          slot.tile:flyAway(n, #self.selectedSlots) -- calls Tile:delete()
          slot.tile = nil
          n = n + 1
        end
      end

      self.selectedSlots[1]:flyAwayScore(score) -- this increments score, updates UI

      self.selectedSlots = {}
      self.swaps = self.swaps + 1

      self:dropColumns()
      self:compactColumns2()

      -- wait for tile transitions to finish (and tiles be deleted) before checking
      timer.performWithDelay(_G.FLIGHT_TIME, function()
        if self:countTiles() < 2 then -- will end automatically with 0 or 1 tiles
          self:gameOver()
        end
      end)
    else
      for _,slot in ipairs(self.selectedSlots) do
        slot.tile:shake()
      end
      self:deselectAllSlots()
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

function Grid:compactColumns2()
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

function Grid:jumble()

  if self.swaps == 0 then
    return
  end

  local tiles = self:getTiles()
  if #tiles < 3 then
    return
  end

  local function reslot(slot)
    slot.tile.slot = slot
    transition.moveTo(slot.tile.grp, {
      x = slot.center.x,
      y = slot.center.y,
      time = _G.FLIGHT_TIME,
      transition = easing.outQuart,
    })
  end

  -- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
  -- https://stackoverflow.com/questions/35572435/how-do-you-do-the-fisher-yates-shuffle-in-lua

  for i=#tiles, 1, -1 do

    local j = math.random(i)
    -- find a random slot with a tile

    local slot1 = tiles[i].slot
    local slot2 = tiles[j].slot

    -- swap the tiles (with transition)
    slot1.tile, slot2.tile = slot2.tile, slot1.tile
    reslot(slot1)
    reslot(slot2)
  end

  self.swaps = self.swaps - 1
  _G.toolBar:setLeft(string.format('⇆ %s', self.swaps))
  _G.toolBar:setCenter(nil)
end

function Grid:addRowAtTop()

  if self.swaps == 0 then
    return
  end

  local tilesAdded = 0
  local topSlot = self:findSlot(1,1)
  while topSlot do
    if topSlot.tile == nil then
      local bottomSlot = topSlot
      while bottomSlot.s do bottomSlot = bottomSlot.s end
      if bottomSlot.tile then
        topSlot:createTile()
        tilesAdded = tilesAdded + 1
      end
    end
    topSlot = topSlot.e
  end

  if tilesAdded > 0 then
    self:dropColumns()
    self.swaps = self.swaps - 1
    _G.toolBar:setLeft(string.format('⇆ %s', self.swaps))
    _G.toolBar:setCenter(nil)
  end

end

return Grid
