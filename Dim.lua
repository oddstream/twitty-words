-- Dim.lua

local Dim = {
  Q = nil,
  halfQ = nil,

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

  o.numX = 7
  o.numY = 10

  local xQ = math.floor(display.actualContentWidth/o.numX)
  local yQ = math.floor(display.actualContentHeight/o.numY)
  trace('Dim reports Qx, Qy', xQ, yQ)

  o.Q = math.min(xQ, yQ)
  o.halfQ = math.floor(o.Q/2)

  o.tileFontSize = o.Q * 0.66

  o.toolBarHeight = o.Q

  -- local contentHeight = display.actualContentHeight - o.toolBarHeight

  -- o.numX = math.floor(display.actualContentWidth / o.Q)
  -- o.numY = math.floor(contentHeight / o.Q)

  o.marginX = (display.actualContentWidth - (o.numX * o.Q)) / 2
  o.marginY = (o.toolBarHeight / 2) + ((display.actualContentHeight - (o.numY * o.Q)) / 2)

  return o
end

return Dim
