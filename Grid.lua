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
}
Grid.__index = Grid

function Grid.new(width, height)
  local o = {}
  setmetatable(o, Grid)

  o.slots = {}
  o.width = width
  o.height = height

  o.score = 0

  o:createSlots()
  o:linkSlots()

  o:createTiles()

  o.selectedSlots = {}

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
  local first, last = string.find(_G.DICTIONARY, '[^%u]' .. word .. '[^%u]')
  return first ~= nil
end

function Grid:createTiles()
  self:iterator(function(s)
    s:createTile()
  end)
end

function Grid:deselectAllSlots()
  self:iterator(function(s)
    s:deselect()
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
    return false
  end

  -- TODO check slot is connected to last selected slot
  -- in case selection extends across nil tiles
  if not table.contains(self.selectedSlots, slot) then
    local last = self.selectedSlots[#self.selectedSlots]
    if not last or connected(slot, last) then
      table.insert(self.selectedSlots, slot)
      local word, score = self:getSelectedWord()
      _G.statusBar:setCenter(word)
    end
  end
end

function Grid:flyAwayScore(slot, score)
  local dim = _G.DIMENSIONS
  local text = display.newText(_G.MUST_GROUPS.grid,
    string.format('+%u', score),
    slot.center.x, slot.center.y,
    _G.TILE_FONT, dim.tileFontSize)
  text:toFront()
  text:setFillColor(unpack(_G.MUST_COLORS.black))
  transition.scaleTo(text, {
    xScale = 0.5,
    yScale = 0.5,
    time = _G.FLIGHT_TIME,
    transition = easing.linear,
  })
  transition.moveTo(text, {
    x = display.contentWidth,
    y = display.contentHeight,
    time = _G.FLIGHT_TIME,
    transition = easing.linear,
    onComplete = function()
      display.remove(text)
      self.score = self.score + score
      _G.statusBar:setRight(tonumber(self.score))
    end,
  })
end

function Grid:testSelection()
  if #self.selectedSlots == 2 then
    local t1 = self.selectedSlots[1].tile
    local t2 = self.selectedSlots[2].tile
    t1.letter, t2.letter = t2.letter, t1.letter
    t1:refreshLetter()
    t2:refreshLetter()
    -- leaving slots selected?
    _G.statusBar:setCenter(string.format('%s ⇆ %s', t1.letter, t2.letter))
  elseif #self.selectedSlots > 2 then
    local word, score = self:getSelectedWord()
    if isWordInDictionary(word) then
      -- trace(word, 'in dictionary, score', score)
      for _,slot in ipairs(self.selectedSlots) do
        slot.tile:flyAway()
        -- slot.tile:delete()
        slot.tile = nil
      end
      self:flyAwayScore(self.selectedSlots[1], score)
      self.selectedSlots = {}
      -- timer.performWithDelay(_G.FLIGHT_TIME, function() self:gravity() end)
      -- timer.performWithDelay(_G.FLIGHT_TIME, function() self:dropColumns() end)
      self:dropColumns()
    else
      -- trace(word, 'NOT in dictionary')
      self:deselectAllSlots()
    end
  end
end
--[[
function Grid:gravity()

  repeat
    local moved = 0
    for _,src in ipairs(self.slots) do
      if src.tile:is() then
        local dst = src.s
        if dst and not dst.tile:is() then
          local letter = src.tile.letter
          src.tile:delete()
          dst:createTile(letter)
          moved = moved + 1
        end
      end
    end
  until moved == 0

end
]]
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

  -- do
  --   print('pre pass')
  --   local s = bottomSlot
  --   while s do
  --     print(s.tile)
  --     s = s.n
  --   end
  -- end

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

  -- do
  --   print('post pass')
  --   local s = bottomSlot
  --   while s do
  --     print(s.tile)
  --     s = s.n
  --   end
  -- end
end

function Grid:dropColumns()
  -- foreach column (find slots with no south link)
  -- (could use slot.y == self.height)
  for _,slot in ipairs(self.slots) do
    if not slot.s then
      self:dropColumn(slot)
    end
  end
end

return Grid
