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

  titleBarHeight = nil,
  statusBarheight = nil,
}
Dim.__index = Dim  -- failed table lookups on the instances should fallback to the class table, to get methods

function Dim.new(Q)
  local o = {}
  setmetatable(o, Dim)

  o.Q = Q

  o.Q50 = math.floor(Q/2)
  o.Q20 = math.floor(Q/5)
  o.Q10 = math.floor(Q/10)

  o.tileFontSize = Q * 0.66

  o.numX = math.floor(display.actualContentWidth / Q)
  o.numY = math.floor(display.actualContentHeight / Q)

  o.marginX = (display.actualContentWidth - (o.numX * Q)) / 2
  o.marginY = (display.actualContentHeight - (o.numY * Q)) / 2

  o.titleBarHeight = display.contentHeight / 16
  o.statusBarheight = display.contentHeight / 24

  return o
end

return Dim
