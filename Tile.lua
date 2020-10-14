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

function Tile.new(slot, letter)
  local dim = _G.DIMENSIONS

  local o = {}
  setmetatable(o, Tile)

  o.slot = slot

  if letter == nil then
    local n = math.random(1, #_G.SCRABBLE_LETTERS)
    o.letter = string.sub(_G.SCRABBLE_LETTERS, n, n)
  else
    o.letter = letter
  end

  o.grp = display.newGroup()
  o.grp.x = slot.center.x
  o.grp.y = slot.center.y
  _G.MUST_GROUPS.grid:insert(o.grp)

  o.rectBack = display.newRoundedRect(o.grp, 0, 0, dim.Q - 10, dim.Q - 10, dim.Q / 20)  -- TODO magic numbers
  o.rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory)) -- if alpha == 0, we don't get tap events

  o.textLetter = display.newText(o.grp, o.letter, 0, 0, _G.TILE_FONT, dim.tileFontSize)
  o.textLetter:setFillColor(unpack(_G.MUST_COLORS.black))

  o.grp:addEventListener('tap', o)
  o.grp:addEventListener('touch', o)

  return o
end

function Tile:is()
  return self.grp ~= nil
end

function Tile:refreshLetter()
  local dim = _G.DIMENSIONS
  assert(self.grp)
  display.remove(self.textLetter)
  self.textLetter = display.newText(self.grp, self.letter, 0, 0, _G.TILE_FONT, dim.tileFontSize)
  self.textLetter:setFillColor(unpack(_G.MUST_COLORS.black))
end

-- function Tile:refreshEventListener()
--   self.grp:removeEventListener('touch', self)
--   self.grp:addEventListener('touch', self)
-- end

function Tile:tap()
  trace('tap', self.letter)
end

function Tile:touch(event)
  -- event.target is self.grp

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y, self.letter)
    -- deselect any selected tiles
    self.slot:deselectAllTiles()

  elseif event.phase == 'moved' then
    -- trace('touch moved', event.x, event.y, self.letter)
    -- inform slot>grid to select tile under x,y

    if self.grp == nil then
      -- don't get touch events if no tile
      -- TODO if slot doesn't have a tile then end the touch
      trace('touch move over nil tile')
    end

    -- adds to selected word/table of selected tiles if tile is not that previously selected
    self.slot:selectTile(event.x, event.y)

  elseif event.phase == 'ended' then
    -- trace('touch ended', event.x, event.y, self.letter)
    -- inform slot>grid to test selected tiles (in the order they were selected)
    self.slot:testSelection()

  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.y, self.letter)
    self.slot:deselectAllTiles()
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

function Tile:flyAway()
--[[
  local dim = _G.DIMENSIONS
  self.grp:toFront()
  -- self.rectBack:setFillColor(unpack(_G.MUST_COLORS.green))
  transition.scaleTo(self.grp, {
    xScale = 0.5,
    yScale = 0.5,
    time = _G.FLIGHT_TIME,
    transition = easing.linear,
    delay = 0,
  })
  transition.moveTo(self.grp, {
    x = (display.contentWidth / 2),  -- + (n * (self.grp.width * 0.5)),
    y = display.contentHeight + dim.statusBarHeight,
    time = _G.FLIGHT_TIME,
    transition = easing.linear,
    delay = 0,
    onComplete = function() self:delete() end,
  })
]]
  self:delete()
end

return Tile
