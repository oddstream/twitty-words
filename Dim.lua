-- Dim.lua

local Dim = {}
Dim.__index = Dim  -- failed table lookups on the instances should fallback to the class table, to get methods

-- "At the beginning of the game, each player draws seven tiles from the bag and places them on their rack"

function Dim.new()
  local o = {}
  setmetatable(o, Dim)

  -- safeAreaInsets reports top=126, left=0, bottom=97, right=0 for iPhone X
  local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

  o.numX = 7
  o.numY = 10

  local xQ = math.floor(display.safeActualContentWidth/o.numX)
  local yQ = math.floor(display.safeActualContentHeight / (o.numY + 1 + 0.5)) -- add for toolbar (1) and statusbar (0.5)
  -- trace('Dim reports Qx, Qy', xQ, yQ)

  o.Q = math.min(xQ, yQ)
  o.halfQ = o.Q/2
  o.Q3D = o.Q * 0.025

  o.tileFontSize = o.Q * 0.75

  o.toolBarHeight = o.Q
  o.toolBarX = display.contentCenterX
  o.toolBarY = topInset + (o.toolBarHeight / 2)
  o.toolBarWidth = display.safeActualContentWidth

  o.statusBarHeight = o.Q / 2
  o.statusBarX = display.contentCenterX
  o.statusBarY = display.safeActualContentHeight - bottomInset - (o.statusBarHeight / 2)
  o.statusBarWidth = display.safeActualContentWidth

  o.baizeHeight = display.safeActualContentHeight - o.toolBarHeight - o.statusBarHeight

  -- o.numX = math.floor(display.actualContentWidth / o.Q)
  -- o.numY = math.floor(contentHeight / o.Q)

  o.marginX = (display.safeActualContentWidth - (o.numX * o.Q)) / 2
  o.marginX = o.marginX + leftInset

  -- TODO this is top margin
  -- o.marginY = o.toolBarHeight + (display.actualContentHeight - (o.numY * o.Q)) / 2
  o.marginY = topInset + o.toolBarHeight
  -- o.marginY = (display.safeActualContentHeight - (o.numY * o.Q)) / 2

  return o
end

return Dim
