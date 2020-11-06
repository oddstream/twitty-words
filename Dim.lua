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
  o.numY = 9

  local xQ = math.floor(display.safeActualContentWidth/o.numX)
  local yQ = math.floor(display.safeActualContentHeight / (o.numY + 1 + 0.5)) -- add for toolbar (1) and statusbar (0.5)
  -- trace('Dim reports Qx, Qy', xQ, yQ)

  o.Q = math.min(xQ, yQ)
  o.halfQ = o.Q/2
  o.Q3D = o.Q * 0.025

  o.tileFontSize = o.Q * 0.75

  o.statusbarHeight = o.Q / 2
  o.statusbarX = display.contentCenterX
  o.statusbarY = topInset + (o.statusbarHeight / 2)
  o.statusbarWidth = display.safeActualContentWidth

  o.wordbarHeight = o.Q
  o.wordbarX = display.contentCenterX
  o.wordbarY = topInset + o.statusbarHeight + (o.wordbarHeight / 2)
  o.wordbarWidth = display.safeActualContentWidth

  o.toolbarHeight = o.Q
  o.toolbarX = display.contentCenterX
  o.toolbarY = display.safeActualContentHeight - (o.toolbarHeight / 2)
  o.toolbarWidth = display.safeActualContentWidth

  o.resultsbarHeight = o.Q / 2
  o.resultsbarX = display.contentCenterX
  o.resultsbarY = topInset + (o.resultsbarHeight / 2)
  o.resultsbarWidth = display.safeActualContentWidth

  o.baizeHeight = display.safeActualContentHeight - o.statusbarHeight - o.toolbarHeight - o.wordbarHeight

  -- o.numX = math.floor(display.actualContentWidth / o.Q)
  -- o.numY = math.floor(contentHeight / o.Q)

  o.marginX = (display.safeActualContentWidth - (o.numX * o.Q)) / 2
  o.marginX = o.marginX + leftInset

  -- TODO this is top margin
  -- o.marginY = ((o.toolbarHeight + o.statusbarHeight + (o.Q * o.numY)) - display.safeActualContentHeight) / 2
  -- o.marginY = o.toolbarHeight + (display.actualContentHeight - (o.numY * o.Q)) / 2
  -- o.marginY = (display.safeActualContentHeight - (o.numY * o.Q)) / 2

  trace('baize', o.baizeHeight, 'tiles', o.numY * o.Q)
  o.marginY = topInset + o.statusbarHeight + o.wordbarHeight + ((o.baizeHeight - (o.numY * o.Q)) / 2)
  return o
end

return Dim
