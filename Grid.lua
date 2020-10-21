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

  composer.gotoScene('HighScores', { params={score=self.score - deductions, words=self.words}, effect='fade' })
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
  _G.statusBar:setLeft(string.format('⇆ %s', self.swaps))
  _G.statusBar:setRight(string.format('%+d', self.score - self:calcResidualScore()))
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
  local first, _ = string.find(_G.DICTIONARY, '[^%u]' .. word .. '[^%u]')
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

function Grid:deselectAllSlots()
  self:iterator(function(slot)
    slot:deselect()
  end)
  self.selectedSlots = {}
  _G.statusBar:setCenter(nil)
end

function Grid:selectSlot(slot)
  assert(slot.tile)

  local function connected(a, b)
    for _,dir in ipairs({'n','ne','e','se','s','sw','w','nw'}) do
      if a[dir] == b then
        return true
      end
    end
    trace('not connected')
    self:deselectAllSlots()
    return false
  end

  -- TODO check slot is connected to last selected slot
  -- in case selection extends across nil tiles
  if not table.contains(self.selectedSlots, slot) then
    local last = self.selectedSlots[#self.selectedSlots]
    if not last or connected(slot, last) then
      table.insert(self.selectedSlots, slot)
      local word, _ = self:getSelectedWord()
      _G.statusBar:setCenter(word)
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
      _G.statusBar:setLeft(string.format('⇆ %s', self.swaps))
      _G.statusBar:setCenter(string.format('%s ⇆ %s', t1.letter, t2.letter))
    end
  end
end
]]
function Grid:testSelection()
  if #self.selectedSlots == 2 then
    if self.swaps > 0 then
      local t1 = self.selectedSlots[1].tile
      local t2 = self.selectedSlots[2].tile
      if t1.letter ~= t2.letter then
        t1.letter, t2.letter = t2.letter, t1.letter
        t1:refreshLetter()
        t2:refreshLetter()

        self.swaps = self.swaps - 1
        _G.statusBar:setLeft(string.format('⇆ %s', self.swaps))
        _G.statusBar:setCenter(string.format('%s ⇆ %s', t1.letter, t2.letter))
      end
    end
    self:deselectAllSlots()
  elseif #self.selectedSlots > 2 then
    local word, score = self:getSelectedWord()
    if isWordInDictionary(word) then
    -- if true then
      trace(score, word)
      table.insert(self.words, word)

      do
        local n = 1
        for _,slot in ipairs(self.selectedSlots) do
          slot.tile:flyAway(n) -- calls Tile:delete()
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
      -- trace(word, 'NOT in dictionary')
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
    slot.center.x = (slot.x * dim.Q) - dim.Q + dim.Q50  -- copied from Slot.new()
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
  if self.swaps > 0 then
    local count = self:countTiles()
    for n=1, count/2 do
      -- find a random slot with a tile
      local slot1
      repeat
        slot1 = self.slots[math.random(1, #self.slots)]
      until slot1.tile

      -- find a different random slot with a tile
      local slot2
      repeat
        slot2 = self.slots[math.random(1, #self.slots)]
      until slot2 ~= slot1 and slot2.tile

      -- swap the tiles (with transition)
      slot1.tile, slot2.tile = slot2.tile, slot1.tile

      slot1.tile.slot = slot1
      transition.moveTo(slot1.tile.grp, {
        x = slot1.center.x,
        y = slot1.center.y,
        time = _G.FLIGHT_TIME,
        transition = easing.outQuart,
      })

      slot2.tile.slot = slot2
      transition.moveTo(slot2.tile.grp, {
        x = slot2.center.x,
        y = slot2.center.y,
        time = _G.FLIGHT_TIME,
        transition = easing.outQuart,
      })
    end
    self.swaps = self.swaps - 1
    _G.statusBar:setLeft(string.format('⇆ %s', self.swaps))
    _G.statusBar:setCenter(nil)
end
end

return Grid
