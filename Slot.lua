-- Slot.lua

local Tile = require 'Tile'

local Slot = {
  grid = nil, -- back link to grid
  x = nil,  -- column index
  y = nil,  -- row index
  center = nil, -- point table, screen coords

  tile = nil, -- tile at this slot, can be nil
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
  o.center.y = dim.titleBarHeight + dim.marginY + o.center.y

  return o
end

function Slot:createTile()
  self.tile = Tile.new(self)
end

function Slot:deselectAll()
  -- plural function goes up the chain to parent (Grid)
  self.grid:deselectAllSlots()
end

function Slot:deselect()
  -- single function goes down the chain to child (Tile)
  if self.tile then
    self.tile:deselect()
  end
end

local function pointInCircle(x, y, cx, cy, radius)
  local distanceSquared = (x - cx) * (x - cx) + (y - cy) * (y - cy)
  return distanceSquared <= radius * radius
end

function Slot:select(x, y)
  if self.tile then
    -- only select this slot if event x/y is within radius of center
    -- otherwise diagonal drags select adjacent tiles
    if pointInCircle(x, y, self.center.x, self.center.y, _G.DIMENSIONS.Q50) then
      self.tile:select()
      self.grid:selectSlot(self)
    -- else
      -- trace('not in circle')
    end
  end
end

--[[
function Slot:tapped()
  -- bubbled up from Tile:tap event handler
  self.grid:tapped(self)  -- bubble up to grid
end
]]

function Slot:testSelection()
  self.grid:testSelection()
end

return Slot
