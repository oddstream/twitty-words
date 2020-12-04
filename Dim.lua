-- Dim.lua

local Dim = {}
Dim.__index = Dim  -- failed table lookups on the instances should fallback to the class table, to get methods

-- "At the beginning of the game, each player draws seven tiles from the bag and places them on their rack"

function Dim.new(width, height)
  local o = {}
  setmetatable(o, Dim)

  -- safeAreaInsets reports top=126, left=0, bottom=97, right=0 for iPhone X
  local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

  o.numX = width
  o.numY = height

  local xQ = math.floor(display.actualContentWidth/o.numX)
  local yQ = math.floor(display.actualContentHeight / (o.numY + 3)) -- add for statusbar, wordbar, toolbar
  -- trace('Dim reports Qx, Qy', xQ, yQ)

  o.Q = math.min(xQ, yQ)
  o.halfQ = o.Q * 0.5
  o.quarterQ = o.Q * 0.24
  o.size3D = o.Q * 0.95
  o.offset3D = o.Q * 0.025

  o.tileFontSize = o.Q * 0.75

  -- o.bannerHeight = o.Q
  -- o.bannerX = display.contentCenterX
  -- o.bannerY = topInset - display.screenOriginY + (o.bannerHeight / 2)
  -- o.bannerWidth = display.actualContentWidth

  o.statusbarHeight = o.Q / 2
  o.statusbarX = display.contentCenterX
  o.statusbarY = topInset - display.screenOriginY + (o.statusbarHeight / 2)
  o.statusbarWidth = display.actualContentWidth

  o.wordbarHeight = o.Q
  o.wordbarX = display.contentCenterX
  o.wordbarY = topInset - display.screenOriginY + o.statusbarHeight + (o.wordbarHeight / 2)
  o.wordbarWidth = display.actualContentWidth

  o.toolbarHeight = o.Q
  o.toolbarX = display.contentCenterX
  o.toolbarY = display.actualContentHeight - (o.toolbarHeight / 2)
  o.toolbarWidth = display.actualContentWidth

  o.baizeHeight = display.actualContentHeight - o.statusbarHeight - o.toolbarHeight - o.wordbarHeight

  -- o.numX = math.floor(display.actualContentWidth / o.Q)
  -- o.numY = math.floor(contentHeight / o.Q)

  trace('baize height', o.baizeHeight, 'tiles height', o.numY * o.Q)

  -- firstTileX, firstTileY is the coord of the centerpoint of the first slot (1,1)
  o.firstTileX = (display.actualContentWidth - (o.numX * o.Q)) / 2
  o.firstTileX = o.firstTileX + leftInset

  -- o.firstTileY = ((o.toolbarHeight + o.statusbarHeight + (o.Q * o.numY)) - display.actualContentHeight) / 2
  -- o.firstTileY = o.toolbarHeight + (display.actualContentHeight - (o.numY * o.Q)) / 2
  -- o.firstTileY = (display.actualContentHeight - (o.numY * o.Q)) / 2

  o.firstTileY = topInset - display.screenOriginY + o.statusbarHeight + o.wordbarHeight + ((o.baizeHeight - (o.numY * o.Q)) / 2)

  return o
end

return Dim
