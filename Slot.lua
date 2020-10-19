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
  self.center = {x=(self.x * dim.Q) - dim.Q + dim.Q50, y=(self.y * dim.Q) - dim.Q + dim.Q50}
  self.center.x = self.center.x + dim.marginX
  self.center.y = dim.titleBarHeight + dim.marginY + self.center.y
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

function Slot:flyAwayScore(score)
  local dim = _G.DIMENSIONS

  local grp = display.newGroup()
    grp.x = self.center.x
    grp.y = self.center.y
  _G.MUST_GROUPS.grid:insert(grp)
  grp:toFront()

  local rectBack = display.newRoundedRect(grp, 0, 0, dim.Q * 0.95, dim.Q * 0.95, dim.Q / 20)  -- TODO magic numbers
    rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory)) -- if alpha == 0, we don't get tap events

  -- force display of sign, in case score is negative
  -- http://www.cplusplus.com/reference/cstdio/printf/
  local textScore = display.newText(grp, string.format('%+d', score), 0, 0, _G.TILE_FONT, dim.tileFontSize * 0.75)
    textScore:setFillColor(unpack(_G.MUST_COLORS.black))

  transition.moveTo(grp, {
    x = display.contentWidth - dim.Q50,
    y = display.contentHeight - dim.Q50,
    time = _G.FLIGHT_TIME,
    transition = easing.outQuad,
    onComplete = function()
      timer.performWithDelay(1000, function() display.remove(grp) end)
    end,
  })
end

return Slot
