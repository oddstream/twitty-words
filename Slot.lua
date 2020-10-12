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
  o.center.y = o.center.y + dim.marginY

  -- TODO title and status bar margins

  return o
end

function Slot:reset()
  if self.tile then
    self.tile:reset()
    self.tile = nil
  end
end

function Slot:createTile()
  self:reset()
  self.tile = Tile.new(self)
end

function Slot:deselectTiles()
  -- plural function goes up the chain to parent (Grid)
  self.grid:deselectTiles()
end

function Slot:deselectTile()
  -- single function goes down the chain to child (Tile)
  if self.tile then
    self.tile:deselect()
  end
end

function Slot:selectTile()
  if self.tile then
    self.tile:select()
    self.grid:selectTile(self.tile)
  end
end

function Slot:testSelection()
  self.grid:testSelection()
end

return Slot
