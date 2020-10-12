-- Grid (of tiles) class

local composer = require('composer')

local Tile = require 'Tile'

local Grid = {
  -- prototype object
  tiles = nil,    -- array of Tile objects
  width = nil,      -- number of columns
  height = nil,      -- number of rows
}
Grid.__index = Grid

function Grid.new(width, height)
  local o = {}
  setmetatable(o, Grid)

  o.tiles = {}
  o.width = width
  o.height = height

  o:createTiles()
  o:linkTiles()

  return o
end

function Grid:reset()
  -- clear out the Tiles
  self:iterator(function(t)
    t:reset()
  end)

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

function Grid:createTiles()
  for y = 1, self.height do
    for x = 1, self.width do
      local t = Tile.new(self, x, y)
      table.insert(self.tiles, t) -- push
    end
  end
end

function Grid:linkTiles()
  for _,t in ipairs(self.tiles) do
    t.n = self:findTile(t.x, t.y - 1)
    t.ne = self:findTile(t.x + 1, t.y - 1)
    t.e = self:findTile(t.x + 1, t.y)
    t.se = self:findTile(t.x + 1, t.y + 1)
    t.s = self:findTile(t.x, t.y + 1)
    t.sw = self:findTile(t.x - 1, t.y + 1)
    t.w = self:findTile(t.x - 1, t.y)
    t.nw = self:findTile(t.x - 1, t.y - 1)
  end
end

function Grid:iterator(fn)
  for _,t in ipairs(self.tiles) do
    fn(t)
  end
end

function Grid:findTile(x,y)
  for _,t in ipairs(self.tiles) do
    if t.x == x and t.y == y then
      return t
    end
  end
  return nil
end

return Grid
