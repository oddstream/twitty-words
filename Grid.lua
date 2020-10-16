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

  o.score = 0
  o.words = {}
  o.swaps = 1

  o:createSlots()
  o:linkSlots()

  o:createTiles()

  o.selectedSlots = {}

  _G.statusBar:setLeft(string.format('⇆ %s', o.swaps))
  _G.statusBar:setRight(string.format('%s', o.score))

  return o
end

function Grid:reset()
  -- clear out the Tiles from the Slots
  -- self:iterator(function(t)
  --   t:reset()
  -- end)

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

  -- self:newLevel()
end

function Grid:newLevel()
  -- self:placeCoins()
  -- self:colorCoins()
  -- self:jumbleCoins()
  -- self:createGraphics()

  -- self.levelText.text = tostring(self.gameState.level)

  -- self:fadeIn()
end

function Grid:advanceLevel()
  -- assert(self.gameState)
  -- assert(self.gameState.level)
  -- self.gameState.level = self.gameState.level + 1
  -- self.levelText.text = tostring(self.gameState.level)
  -- self.gameState:write()
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
function Grid:flyAwayScore(slot, score)
  local dim = _G.DIMENSIONS

  local grp = display.newGroup()
    grp.x = slot.center.x
    grp.y = slot.center.y
  _G.MUST_GROUPS.grid:insert(grp)
  grp:toFront()

  local rectBack = display.newRoundedRect(grp, 0, 0, dim.Q * 0.95, dim.Q * 0.95, dim.Q / 20)  -- TODO magic numbers
    rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory)) -- if alpha == 0, we don't get tap events

  local textScore = display.newText(grp, string.format('+%u', score), 0, 0, _G.TILE_FONT, dim.tileFontSize * 0.75)
    textScore:setFillColor(unpack(_G.MUST_COLORS.black))

  -- transition.scaleTo(grp, {
  --   xScale = 0.5,
  --   yScale = 0.5,
  --   time = _G.FLIGHT_TIME,
  --   transition = easing.linear,
  -- })
  transition.moveTo(grp, {
    x = display.contentWidth - dim.Q50,
    y = display.contentHeight - dim.Q50,
    time = _G.FLIGHT_TIME,
    transition = easing.outQuad,
    onComplete = function()
      display.remove(grp)
      self.score = self.score + score
      _G.statusBar:setRight(tonumber(self.score))
    end,
  })
end

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

      self:flyAwayScore(self.selectedSlots[#self.selectedSlots], score)
      self.selectedSlots = {}
      self:dropColumns()
      self:compactColumns2()
      self.swaps = self.swaps + 1
      _G.statusBar:setLeft(string.format('⇆ %s', self.swaps))
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
    -- dst.tile:delete()
    -- dst.tile = Tile.new(dst, 'X')
    if dst.tile then
      -- assert( dst.tile.grp.y ~= dst.center.y )
      -- trace('removing cloned tile.grp at', dst.x, ',', dst.y, 'letter', dst.tile.letter)
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
--[[
function Grid:compactColumns()
  -- find empty column with a non-empty column to it's right (cols 1,2,3)
  -- or a non-empty column to it's left (cols 5,6,7)
  -- check behaviour when center column is empty

  local function _calcHeights()
    local arr = {}
    for col = 1, self.width do
      arr[col] = 0
      local slot = self:findSlot(col, 1)
      while slot do
        if slot.tile then
          arr[col] = arr[col] + 1
        end
        slot = slot.s
      end
    end
    return arr
  end

  local mid = math.floor(self.width / 2)
  local heights = _calcHeights()
  local moved
  repeat
    moved = false

    for i = 1, mid-1 do -- eg 1,2,3
      if heights[i] > 0 and heights[i+1] == 0 then
        self:slideColumn(i, 'e')
        heights[i+1] = heights[i]
        heights[i] = 0
        moved = true
      end
    end

    for i = self.width, mid+1, -1 do  -- eg 7,6,5
      if heights[i] > 0 and heights[i-1] == 0 then
        self:slideColumn(i, 'w')
        heights[i-1] = heights[i]
        heights[i] = 0
        moved = true
      end
    end

  until moved == false

end
]]
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
  for x=1, self.width do
    for y=1, self.height do
      -- TODO use iterator
      local slot = self:findSlot(x,y)
      slot.center.x = (x*dim.Q) - dim.Q + dim.Q50  -- copied from Slot.new()
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

end

return Grid
