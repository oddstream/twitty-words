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

  o.titleBarHeight = display.contentHeight / 16
  o.statusBarHeight = display.contentHeight / 24

  local contentHeight = display.actualContentHeight - o.titleBarHeight - o.statusBarHeight

  o.numX = math.floor(display.actualContentWidth / Q)
  o.numY = math.floor(contentHeight / Q)

  o.marginX = (display.actualContentWidth - (o.numX * Q)) / 2
  o.marginY = (contentHeight - (o.numY * Q)) / 2

  return o
end

return Dim
