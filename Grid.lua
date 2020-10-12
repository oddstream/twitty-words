-- Grid (of Slots) class

local composer = require('composer')

local Slot = require 'Slot'

local Grid = {
  -- prototype object
  slots = nil,    -- array of Tile objects
  width = nil,      -- number of columns
  height = nil,      -- number of rows

  selectedTiles = nil,  -- table of selected tiles, in order they were selected
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

  o:createTiles()

  o.selectedTiles = {}

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

  self:newLevel()
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
  for _,t in ipairs(self.selectedTiles) do
    word = word .. t.letter
  end
  return word
end

function Grid:createTiles()
  self:iterator(function(s)
    s:createTile()
  end)
end

function Grid:deselectTiles()
  self:iterator(function(s)
    s:deselectTile()
  end)
  self.selectedTiles = {}
end

function Grid:selectTile(t)
  if t ~= self.selectedTiles[#self.selectedTiles] then
    table.insert(self.selectedTiles, t)
    trace('selected word', self:getSelectedWord())
  end
end

function Grid:testSelection()
  if #self.selectedTiles == 2 then
    local t1 = self.selectedTiles[1]
    local t2 = self.selectedTiles[2]
    t1.letter, t2.letter = t2.letter, t1.letter
    t1:refreshLetter()
    t2:refreshLetter()
  elseif #self.selectedTiles > 2 then
    trace('test selected word against dictionary', self:getSelectedWord())
    for _,t in ipairs(self.selectedTiles) do
      t:delete()
    end
    self.selectedTiles = {}
    -- TODO gravity
  end
end

return Grid
