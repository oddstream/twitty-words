-- Tile.lua

local Tile = {
  slot = nil,

  letter = nil, -- A..Z
  selected = nil, -- boolean (or a number, dunno yet)

  grp = nil,  -- group of graphic objects
    rectBack = nil,
    textLetter = nil,
}
Tile.__index = Tile

function Tile.new(slot)
  local dim = _G.DIMENSIONS

  local o = {}
  setmetatable(o, Tile)

  o.slot = slot

  do
    local n = math.random(1, #_G.SCRABBLE_LETTERS)
    o.letter = string.sub(_G.SCRABBLE_LETTERS, n, n)
  end

  o.grp = display.newGroup()
  o.grp.x = slot.center.x
  o.grp.y = slot.center.y
  _G.MUST_GROUPS.grid:insert(o.grp)

  o.rectBack = display.newRoundedRect(o.grp, 0, 0, dim.Q - 10, dim.Q - 10, dim.Q / 20)  -- TODO magic numbers
  o.rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory)) -- if alpha == 0, we don't get tap events

  o.textLetter = display.newText(o.grp, o.letter, 0, 0, _G.TILE_FONT, dim.tileFontSize)
  o.textLetter:setFillColor(unpack(_G.MUST_COLORS.black))

  o.grp:addEventListener('touch', o)

  return o
end

function Tile:refreshLetter()
  local dim = _G.DIMENSIONS
  display.remove(self.textLetter)
  self.textLetter = display.newText(self.grp, self.letter, 0, 0, _G.TILE_FONT, dim.tileFontSize)
  self.textLetter:setFillColor(unpack(_G.MUST_COLORS.black))
end

local function pointInCircle(x, y, cx, cy, radius)
  local distanceSquared = (x - cx) * (x - cx) + (y - cy) * (y - cy)
  return distanceSquared <= radius * radius
end

function Tile:touch(event)
  -- event.target is self.grp

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y)
    -- deselect any selected tiles
    self.slot:deselectTiles()
  elseif event.phase == 'moved' then
    -- trace('touch moved', event.x, event.y)
    -- inform slot>grid to select tile under x,y
    -- adds to selected word/table of selected tiles if tile is not that previously selected
    if pointInCircle(event.x, event.y, self.slot.center.x, self.slot.center.y, _G.DIMENSIONS.Q50) then
      -- only select this tile if event x/y is within radius of tile center
      -- otherwise diagonal drags select adjacent tiles
      self.slot:selectTile()
    -- else
    --   trace(event.x, event.y, 'outside', self.slot.center.x, self.slot.center.y, _G.DIMENSIONS.Q50)
    -- TODO if slot doesn't have a tile then cancel the touch
    end
  elseif event.phase == 'ended' or event.phase == 'cancelled' then
    -- trace('touch ended/cancelled', event.x, event.y)
    -- inform slot>grid to test selected tiles (in the order they were selected)
    self.slot:testSelection()
  end

  return true
end

function Tile:select()
  self.selected = true
  self.rectBack:setFillColor(unpack(_G.MUST_COLORS.gold))
end

function Tile:deselect()
  self.selected = false
  self.rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory))
end

function Tile:delete()
  self.grp:removeEventListener('touch', self)
  display.remove(self.grp)
  self.grp = nil
  self.slot.tile = nil
end

return Tile
