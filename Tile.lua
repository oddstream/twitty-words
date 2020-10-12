-- Tile.lua

local Tile = {
  grid = nil,
  x = nil,
  y = nil,
  center = nil, -- point table, screen coords

  letter = nil, -- a..z or nil if tile not shown
  selected = nil, -- boolean

  grp = nil,  -- group of graphic objects
    rectBack = nil,
    textLetter = nil,
}
Tile.__index = Tile

function Tile.new(grid, x, y)
  local dim = _G.DIMENSIONS

  local o = {}
  setmetatable(o, Tile)

  o.grid = grid

  do
    local n = math.random(1, #_G.SCRABBLE_LETTERS)
    o.letter = string.sub(_G.SCRABBLE_LETTERS, n, n)
  end

  o.x = x
  o.y = y

  -- calculate where the screen coords center point will be
  o.center = {x=(x*dim.Q) - dim.Q + dim.Q50, y=(y*dim.Q) - dim.Q + dim.Q50}
  o.center.x = o.center.x + dim.marginX
  o.center.y = o.center.y + dim.marginY

  o.grp = display.newGroup()
  o.grp.x = o.center.x
  o.grp.y = o.center.y

  _G.MUST_GROUPS.grid:insert(o.grp)

  o.rectBack = display.newRoundedRect(o.grp, 0, 0, dim.Q - 10, dim.Q - 10, dim.Q / 20)
  o.rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory)) -- if alpha == 0, we don't get tap events

  o.textLetter = display.newText(o.grp, o.letter, 0, 0, _G.TILE_FONT, dim.Q * 0.75)
  o.textLetter:setFillColor(unpack(_G.MUST_COLORS.black))

  return o
end

return Tile
