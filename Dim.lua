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

  -- o.bannerHeight = o.Q
  -- o.bannerX = display.contentCenterX
  -- o.bannerY = topInset - display.screenOriginY + (o.bannerHeight / 2)
  -- o.bannerWidth = display.safeActualContentWidth

  o.statusbarHeight = o.Q / 2
  o.statusbarX = display.contentCenterX
  o.statusbarY = topInset - display.screenOriginY + (o.statusbarHeight / 2)
  o.statusbarWidth = display.safeActualContentWidth

  o.wordbarHeight = o.Q
  o.wordbarX = display.contentCenterX
  o.wordbarY = topInset - display.screenOriginY + o.statusbarHeight + (o.wordbarHeight / 2)
  o.wordbarWidth = display.safeActualContentWidth

  o.resultsbarHeight = o.Q / 2
  o.resultsbarX = display.contentCenterX
  o.resultsbarY = topInset - display.screenOriginY + (o.resultsbarHeight / 2)
  o.resultsbarWidth = display.safeActualContentWidth

  o.toolbarHeight = o.Q
  o.toolbarX = display.contentCenterX
  o.toolbarY = display.safeActualContentHeight - (o.toolbarHeight / 2)
  o.toolbarWidth = display.safeActualContentWidth

  o.baizeHeight = display.safeActualContentHeight - o.statusbarHeight - o.toolbarHeight - o.wordbarHeight

  -- o.numX = math.floor(display.actualContentWidth / o.Q)
  -- o.numY = math.floor(contentHeight / o.Q)

  trace('baize height', o.baizeHeight, 'tiles height', o.numY * o.Q)

  -- firstTileX, firstTileY is the coord of the centerpoint of the first slot (1,1)
  o.firstTileX = (display.safeActualContentWidth - (o.numX * o.Q)) / 2
  o.firstTileX = o.firstTileX + leftInset

  -- o.firstTileY = ((o.toolbarHeight + o.statusbarHeight + (o.Q * o.numY)) - display.safeActualContentHeight) / 2
  -- o.firstTileY = o.toolbarHeight + (display.actualContentHeight - (o.numY * o.Q)) / 2
  -- o.firstTileY = (display.safeActualContentHeight - (o.numY * o.Q)) / 2

  o.firstTileY = topInset - display.screenOriginY + o.statusbarHeight + o.wordbarHeight + ((o.baizeHeight - (o.numY * o.Q)) / 2)

  return o
end

return Dim
