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

  local o = {}
  setmetatable(o, Slot)

  o.grid = grid
  o.x = x
  o.y = y

  o:position()

  return o
end

function Slot:position()
  local dim = _G.DIMENSIONS
  -- calculate where the screen coords center point will be
  self.center = {x=(self.x * dim.Q) - dim.Q + dim.halfQ, y=(self.y * dim.Q) - dim.Q + dim.halfQ}
  self.center.x = self.center.x + dim.firstTileX
  self.center.y = dim.firstTileY + self.center.y
end

function Slot:createTile(letter)
  if letter == nil then
    letter = table.remove(self.grid.letterPool)
  end
  if letter then
    self.tile = Tile.new(self, letter)
    self.tile:addEventListener()
  end
  return letter ~= nil
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
    if pointInCircle(x, y, self.center.x, self.center.y, _G.DIMENSIONS.Q / 3.33) then
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

function Slot:flyAwaySwaps(n)
  local dim = _G.DIMENSIONS

  local grp = Tile.createGraphics(self.center.x, self.center.y, string.format('%+d', n))
  grp.xScale, grp.yScale = 0.5, 0.5

  transition.moveTo(grp, {
    x = dim.halfQ,
    y = dim.toolbarY,
    time = _G.FLIGHT_TIME,
    transition = easing.outQuad,
    onComplete = function()
      self.grid.swaps = self.grid.swaps + n
      transition.scaleTo(grp, {
        xScale = 0.1,
        yScale = 0.1,
        time = 500,
        onComplete = function()
          display.remove(grp)
          self.grid:updateUI()
        end
      })
    end,
  })
end

function Slot:flyAwayScore(score)
  local dim = _G.DIMENSIONS

  -- force display of sign, in case score is negative
  -- http://www.cplusplus.com/reference/cstdio/printf/
  local grp = Tile.createGraphics(self.center.x, self.center.y, string.format('%+d', score))

  transition.moveTo(grp, {
    -- x = display.actualContentWidth - dim.halfQ,
    -- y = dim.toolbarY,
    x = dim.statusbarX,
    y = dim.statusbarY,
    time = _G.FLIGHT_TIME,
    transition = easing.outQuad,
    onComplete = function()
      self.grid.score = self.grid.score + score
      transition.scaleTo(grp, {
        xScale = 0.1,
        yScale = 0.1,
        time = 500,
        onComplete = function() display.remove(grp) end
      })
    end,
  })
end

return Slot
