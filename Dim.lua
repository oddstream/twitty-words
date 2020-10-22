-- Dim.lua

local Dim = {
  Q = nil,

  Q50 = nil,
  Q20 = nil,
  Q10 = nil,

  numX = nil,
  numY = nil,

  marginX = nil,
  marginY = nil,

  toolBarheight = nil,
}
Dim.__index = Dim  -- failed table lookups on the instances should fallback to the class table, to get methods

-- "At the beginning of the game, each player draws seven tiles from the bag and places them on their rack"

function Dim.new()
  local o = {}
  setmetatable(o, Dim)

  o.Q = math.floor(display.actualContentWidth/7)

  o.Q50 = math.floor(o.Q/2)
  o.Q20 = math.floor(o.Q/5)
  o.Q10 = math.floor(o.Q/10)

  o.tileFontSize = o.Q * 0.66

  o.toolBarHeight = o.Q

  local contentHeight = display.actualContentHeight - o.toolBarHeight

  o.numX = math.floor(display.actualContentWidth / o.Q)
  o.numY = math.floor(contentHeight / o.Q)

  o.marginX = (display.actualContentWidth - (o.numX * o.Q)) / 2
  o.marginY = o.toolBarHeight + ((contentHeight - (o.numY * o.Q)) / 2)

  return o
end

return Dim
