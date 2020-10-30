-- Tile.lua

local Tile = {
  slot = nil,

  letter = nil, -- A..Z
  selected = nil, -- boolean (or a number, dunno yet)

  grp = nil,  -- group of graphic objects
}
Tile.__index = Tile

function Tile.new(slot, letter)

  local o = {}
  setmetatable(o, Tile)

  o.slot = slot

  -- do
  --   local n = math.random(1, #_G.SCRABBLE_LETTERS)
  --   o.letter = string.sub(_G.SCRABBLE_LETTERS, n, n)
  -- end
  o.letter = letter

  o.grp = o.createGraphics(slot.center.x, slot.center.y, o.letter)
  _G.MUST_GROUPS.grid:insert(o.grp)

  -- don't add event listers here, as tiles are also used for displaying found words and high scores
  -- o.grp:addEventListener('tap', o)
  -- o.grp:addEventListener('touch', o)

  return o
end

function Tile:addEventListener()
  self.grp:addEventListener('touch', self)
end

function Tile.createGraphics(x, y, letter)
  local dim = _G.DIMENSIONS

  local grp = display.newGroup()
  grp.x = x
  grp.y = y

  -- grp[1]
  local rectShadow = display.newRoundedRect(grp, dim.Q3D, dim.Q3D, dim.Q * 0.95, dim.Q * 0.95, dim.Q / 20)  -- TODO magic numbers
  rectShadow:setFillColor(0.2,0.2,0.2) -- if alpha == 0, we don't get tap events

  -- grp[2]
  local rectBack = display.newRoundedRect(grp, 0, 0, dim.Q * 0.95, dim.Q * 0.95, dim.Q / 20)  -- TODO magic numbers

  -- rectBack:setFillColor(unpack(_G.MUST_COLORS.ivory)) -- if alpha == 0, we don't get tap events
  rectBack:setFillColor(1,1,1) -- if alpha == 0, we don't get tap events
  local paint = {
    type = 'image',
    -- filename = 'assets/Light-Wood-Background-Texture-1536x1024.jpg',
    filename = 'assets/tile' .. tostring(math.random(1,4) .. '.png'),
    baseDir = system.ResourceDirectory,
  }
  rectBack.fill = paint

  -- grp[3]
  local tileFontSize = dim.tileFontSize
  if string.len(letter) > 1 then
    tileFontSize = tileFontSize * 0.66
  end
  -- tried a highlight on the letter; can't see it against ivory background
  -- local textHighlight = display.newText(grp, letter, -(dim.Q / 30), -(dim.Q / 30), _G.TILE_FONT, tileFontSize)
  -- textHighlight:setFillColor(unpack(_G.MUST_COLORS.white))

  local textLetter = display.newText(grp, letter, 0, 0, _G.TILE_FONT, tileFontSize)
  textLetter:setFillColor(unpack(_G.MUST_COLORS.black))

  -- transition.moveTo(grp, {
  --   x = x,
  --   y = y,
  --   time = _G.FLIGHT_TIME,
  --   transition = easing.outQuart,
  -- })

  return grp
end

function Tile:refreshLetter()
  local dim = _G.DIMENSIONS

  local textLetter = self.grp[3]
  display.remove(textLetter)
  textLetter = display.newText(self.grp, self.letter, 0, 0, _G.TILE_FONT, dim.tileFontSize)
  textLetter:setFillColor(unpack(_G.MUST_COLORS.black))
end

function Tile:depress()
  local dim = _G.DIMENSIONS

  local rectShadow = self.grp[1]
  rectShadow.x = 0
  rectShadow.y = 0
  local rectBack = self.grp[2]
  rectBack.x = dim.Q3D
  rectBack.y = dim.Q3D
  local textLetter = self.grp[3]
  textLetter.x = dim.Q3D
  textLetter.y = dim.Q3D
end

function Tile:undepress()
  local dim = _G.DIMENSIONS

  local rectShadow = self.grp[1]
  rectShadow.x = dim.Q3D
  rectShadow.y = dim.Q3D
  local rectBack = self.grp[2]
  rectBack.x = 0
  rectBack.y = 0
  local textLetter = self.grp[3]
  textLetter.x = 0
  textLetter.y = 0
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
    -- self:depress()
    self.slot:select(event.x, event.y)

  elseif event.phase == 'moved' then
    -- trace('touch moved', event.x, event.y, self.letter)
    -- inform slot>grid to select tile under x,y
    -- self:depress()
    -- adds to selected word/table of selected tiles if tile is not that previously selected
    self.slot:select(event.x, event.y)

  elseif event.phase == 'ended' then
    -- trace('touch ended', event.x, event.y, self.letter)
    -- inform slot>grid to test selected tiles (in the order they were selected)
    -- self:undepress()
    self.slot:testSelection()

  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.y, self.letter)
    -- self:undepress()
    self.slot:deselectAll()
  end

  return true
end

function Tile:select()
  self.selected = true
  self.grp[2]:setFillColor(unpack(_G.MUST_COLORS.moccasin))
  self:depress()
end

function Tile:deselect()
  self.selected = false
  -- self.grp[2]:setFillColor(unpack(_G.MUST_COLORS.ivory))
  self.grp[2]:setFillColor(1,1,1)
  self:undepress()
end

function Tile:delete()
  -- When you remove a display object, event listeners that are attached to it — tap and touch listeners,
  -- for example — are also freed from memory.
  -- self.grp:removeEventListener('touch', self)
  display.remove(self.grp)
  self.grp = nil
end

function Tile:shake()
  -- trace('shaking', tostring(self))
  transition.to(self.grp, {time=50, transition=easing.continuousLoop, x=self.grp.x + 10})
  transition.to(self.grp, {delay=50, time=50, transition=easing.continuousLoop, x=self.grp.x - 10})
end

function Tile:flyAway(n, wordLength)
  local dim = _G.DIMENSIONS

  self.grp:toFront()

  transition.moveTo(self.grp, {
    x = (dim.halfQ + (dim.Q * (n-1))) + ((display.contentWidth / 2) - ((dim.Q * wordLength) / 2)),
    y = dim.halfQ,
    time = _G.FLIGHT_TIME,
    transition = easing.outQuad,
  })
  transition.fadeOut(self.grp, {
    time = _G.FLIGHT_TIME,
    transition = easing.linear,
    onComplete = function() self:delete() end,
  })
end

return Tile
