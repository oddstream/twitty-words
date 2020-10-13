-- Slot.lua

local Tile = require 'Tile'

local Slot = {
  grid = nil, -- back link to grid
  x = nil,  -- column index
  y = nil,  -- row index
  center = nil, -- point table, screen coords

  tile = nil,
}
Slot.__index = Slot

function Slot.new(grid, x, y)
  local dim = _G.DIMENSIONS

  local o = {}
  setmetatable(o, Slot)

  o.grid = grid
  o.x = x
  o.y = y

  -- calculate where the screen coords center point will be
  o.center = {x=(x*dim.Q) - dim.Q + dim.Q50, y=(y*dim.Q) - dim.Q + dim.Q50}
  o.center.x = o.center.x + dim.marginX
  o.center.y = dim.statusBarHeight + dim.marginY + o.center.y

  -- TODO title and status bar margins

  return o
end

function Slot:reset()
  if self.tile and self.tile:is() then
    self.tile:reset()
  end
end

function Slot:createTile(letter)
  self:reset()
  self.tile = Tile.new(self, letter)
end

function Slot:deselectAllTiles()
  -- plural function goes up the chain to parent (Grid)
  self.grid:deselectAllTiles()
end

function Slot:deselectTile()
  -- single function goes down the chain to child (Tile)
  if self.tile and self.tile:is() then
    self.tile:deselect()
  end
end

local function pointInCircle(x, y, cx, cy, radius)
  local distanceSquared = (x - cx) * (x - cx) + (y - cy) * (y - cy)
  return distanceSquared <= radius * radius
end

function Slot:selectTile(x, y)
  if self.tile:is() then
    -- only select this tile if event x/y is within radius of tile center
    -- otherwise diagonal drags select adjacent tiles
    if pointInCircle(x, y, self.center.x, self.center.y, _G.DIMENSIONS.Q50) then
      self.tile:select()
      self.grid:selectTile(self.tile)
    end
  end
end

function Slot:testSelection()
  self.grid:testSelection()
end

return Slot
