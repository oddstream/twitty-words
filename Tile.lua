-- Tile.lua

local Tile = {
  slot = nil,

  letter = nil, -- A..Z
  selected = nil, -- boolean (or a number, dunno yet)

  grp = nil,  -- group of graphic objects
    rectShadow = nil,
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

  o.rectShadow = display.newRoundedRect(o.grp, dim.Q * 0.05, dim.Q * 0.05, dim.Q * 0.95, dim.Q * 0.95, dim.Q / 20)  -- TODO magic numbers
  o.rectShadow:setFillColor(0.2,0.2,0.2) -- if alpha == 0, we don't get tap events

  o.rectBack = display.newRoundedRect(o.grp, 0, 0, dim.Q * 0.95, dim.Q * 0.95, dim.Q / 20)  -- TODO magic numbers
  o.rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory)) -- if alpha == 0, we don't get tap events

  o.textLetter = display.newText(o.grp, o.letter, 0, 0, _G.TILE_FONT, dim.tileFontSize)
  o.textLetter:setFillColor(unpack(_G.MUST_COLORS.black))

  -- o.grp:addEventListener('tap', o)
  o.grp:addEventListener('touch', o)

  return o
end

function Tile:refreshLetter()
  local dim = _G.DIMENSIONS

  display.remove(self.textLetter)
  self.textLetter = display.newText(self.grp, self.letter, 0, 0, _G.TILE_FONT, dim.tileFontSize)
  self.textLetter:setFillColor(unpack(_G.MUST_COLORS.black))
end

--[[
function Tile:tap()
  trace('tap', self.letter)
  self:select()
  self.slot:tapped()
end
]]

function Tile:touch(event)
  -- event.target is self.grp

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y, self.letter)
    -- deselect any selected tiles
    self.slot:deselectAll()

  elseif event.phase == 'moved' then
    -- trace('touch moved', event.x, event.y, self.letter)
    -- inform slot>grid to select tile under x,y

    -- adds to selected word/table of selected tiles if tile is not that previously selected
    self.slot:select(event.x, event.y)

  elseif event.phase == 'ended' then
    -- trace('touch ended', event.x, event.y, self.letter)
    -- inform slot>grid to test selected tiles (in the order they were selected)
    self.slot:testSelection()

  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.y, self.letter)
    self.slot:deselectAll()
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
  -- When you remove a display object, event listeners that are attached to it — tap and touch listeners,
  -- for example — are also freed from memory.
  -- self.grp:removeEventListener('touch', self)
  display.remove(self.grp)
  self.grp = nil
end

function Tile:flyAway(n)
  local dim = _G.DIMENSIONS

  self.grp:toFront()
  self.rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory))
  transition.moveTo(self.grp, {
    x = (dim.Q * n) - dim.Q50,
    y = display.contentHeight + dim.Q50,
    time = _G.FLIGHT_TIME,
    transition = easing.outQuart,
    delay = 0,
    onComplete = function() self:delete() end,
  })
end

return Tile
