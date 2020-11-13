-- Tile.lua

local Tile = {}
Tile.__index = Tile

function Tile.new(slot, letter)

  local o = {}
  setmetatable(o, Tile)

  o.slot = slot

  o.letter = letter

  o.grp = o.createGraphics(slot.center.x, slot.center.y, o.letter)
  _G.TWITTY_GROUPS.grid:insert(o.grp)

  -- don't add event listers here, as tiles are also used for displaying found words and high scores

  o.selected = false

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
  local rectShadow = display.newRoundedRect(grp, dim.Q3D, dim.Q3D, dim.Q * 0.95, dim.Q * 0.95, dim.Q / 15)  -- TODO magic numbers
  rectShadow:setFillColor(0.2,0.2,0.2)

  -- grp[2]
  local rectBack = display.newRoundedRect(grp, 0, 0, dim.Q * 0.95, dim.Q * 0.95, dim.Q / 15)  -- TODO magic numbers
--[[
  local paint = {
    type = 'image',
    filename = 'assets/tile' .. tostring(math.random(1,5) .. '.png'),
    baseDir = system.ResourceDirectory,
  }
  rectBack.fill = paint
  -- tried rotating 90, 270 degrees; it looked messy
  if math.random() < 0.5 then
    rectBack.rotation = 180
  end
]]
  -- if alpha == 0, we don't get tap events
  -- set fill color AFTER applying paint
  rectBack:setFillColor(unpack(_G.TWITTY_COLORS.tile))

  -- grp[3]
  local tileFontSize = dim.tileFontSize
  if string.len(letter) > 3 then
    tileFontSize = tileFontSize * 0.5
  elseif string.len(letter) > 1 then
    tileFontSize = tileFontSize * 0.666
  end
  -- tried a highlight on the letter; can't see it against ivory background
  -- local textHighlight = display.newText(grp, letter, -(dim.Q / 30), -(dim.Q / 30), _G.ACME, tileFontSize)
  -- textHighlight:setFillColor(unpack(_G.TWITTY_COLORS.white))

  local textLetter = display.newText(grp, letter, 0, 0, _G.ACME, tileFontSize)
  textLetter:setFillColor(unpack(_G.TWITTY_COLORS.black))

  -- grp[4]
  -- makes the grid harder to scan
  -- if string.len(letter) == 1 and _G.SCRABBLE_SCORES[letter] then
  --   local textScore = display.newText(grp, tostring(_G.SCRABBLE_SCORES[letter]), dim.Q / 3, dim.Q / 3, _G.ACME, tileFontSize / 3)
  --   textScore:setFillColor(unpack(_G.TWITTY_COLORS.black))
  -- end

  return grp
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
  -- event.id
  -- event.target is self.grp
  -- event.name is 'touch'
  -- event.phase
  -- event.pressure
  -- event.time
  -- event.x / event.y
  -- event.xStart / event.yStart

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y, self.letter)
    -- deselect any selected tiles
    self.slot:deselectAll()
    self.slot:select(event.x, event.y)

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
  self.grp[2]:setFillColor(unpack(_G.TWITTY_COLORS.selected))
  self:depress()
end

function Tile:deselect()
  self.selected = false
  self.grp[2]:setFillColor(unpack(_G.TWITTY_COLORS.tile))
  self:undepress()
end

function Tile:mark()
  self.grp[2]:setFillColor(unpack(_G.TWITTY_COLORS.marked))
end

function Tile:unmark()
  self.grp[2]:setFillColor(unpack(_G.TWITTY_COLORS.tile))
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

function Tile:settle()
  transition.moveTo(self.grp, {
    x = self.slot.center.x,
    y = self.slot.center.y,
    time = _G.FLIGHT_TIME / 2,
    transition = easing.outQuad,
  })
end

function Tile:flyAway(n, wordLength)
  local dim = _G.DIMENSIONS

  self.grp:toFront()

  transition.moveTo(self.grp, {
    -- x = (dim.halfQ + (dim.Q * (n-1))) + ((display.actualContentWidth / 2) - ((dim.Q * wordLength) / 2)),
    x = (dim.halfQ / 2) + (dim.halfQ * (n-1)) + ((display.actualContentWidth / 2) - ((dim.halfQ * wordLength) / 2)),
    y = dim.wordbarY,
    time = _G.FLIGHT_TIME,
    transition = easing.outQuad,
  })
  -- transition.fadeOut(self.grp, {
  --   time = _G.FLIGHT_TIME,
  --   transition = easing.linear,
  --   onComplete = function() self:delete() end,
  -- })
  transition.scaleTo(self.grp, {
    xScale = 0.5,
    yScale = 0.5,
    time = _G.FLIGHT_TIME,
    transition = easing.linear,
    onComplete = function() self:delete() end,
  })
end

return Tile
