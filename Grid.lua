-- Grid (of Slots) class

local composer = require('composer')

local Statusbar = require 'Statusbar'
local Slot = require 'Slot'

local Grid = {
  -- prototype object
  slots = nil,    -- array of Tile objects
  width = nil,      -- number of columns
  height = nil,      -- number of rows

  selectedTiles = nil,  -- table of selected tiles, in order they were selected
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
  for _,t in ipairs(self.selectedTiles) do
    word = word .. t.letter
    score = score + _G.SCRABBLE_SCORES[t.letter]
  end
  return word, score * score
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

function Grid:deselectAllTiles()
  self:iterator(function(s)
    s:deselectTile()
  end)
  self.selectedTiles = {}
  _G.statusBar:setCenter(nil)
end

function Grid:selectTile(t)
  if t ~= self.selectedTiles[#self.selectedTiles] then
    table.insert(self.selectedTiles, t)
    local word, score = self:getSelectedWord()
    _G.statusBar:setCenter(word)
  end
end

function Grid:testSelection()
  if #self.selectedTiles == 2 then
    local t1 = self.selectedTiles[1]
    local t2 = self.selectedTiles[2]
    t1.letter, t2.letter = t2.letter, t1.letter
    t1:refreshLetter()
    t2:refreshLetter()
    _G.statusBar:setCenter(nil)
  elseif #self.selectedTiles > 2 then
    local word, score = self:getSelectedWord()
    if isWordInDictionary(word) then
      trace(word, 'in dictionary, score', score)
      self.score = self.score + score
      _G.statusBar:setRight(tonumber(self.score))
      for _,t in ipairs(self.selectedTiles) do
        t:delete()
      end
      self.selectedTiles = {}
      self:gravity()
    else
      trace(word, 'NOT in dictionary')
      self:deselectAllTiles()
    end
  end
end

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

return Grid
