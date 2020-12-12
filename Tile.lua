-- Tile.lua

local const = require 'constants'
local globalData = require 'globalData'

local Tile = {}
Tile.__index = Tile

function Tile.new(slot, letter)

  local o = {}
  setmetatable(o, Tile)

  o.slot = slot

  o.letter = letter

  o.grp = o.createGraphics(globalData.gridGroup, slot.center.x, slot.center.y, o.letter)

  -- don't add event listers here, as tiles are also used for displaying found words and high scores

  o.selected = false

  return o
end

function Tile:addTouchListener()
  self.grp:addEventListener('touch', self)
end

function Tile:removeTouchListener()
  self.grp:removeEventListener('touch', self)
end

function Tile.createGraphics(parent, x, y, letter)
  local dim = globalData.dim

  local grp = display.newGroup()
  grp.x = x
  grp.y = y
  parent:insert(grp)

  local radius = dim.Q / 15

  -- grp[1]
  local rectShadow = display.newRoundedRect(grp, dim.offset3D, dim.offset3D, dim.size3D, dim.size3D, radius)
  rectShadow:setFillColor(unpack(const.COLORS.shadow))

  -- grp[2]
  local rectBack = display.newRoundedRect(grp, 0, 0, dim.size3D, dim.size3D, radius)
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
  rectBack:setFillColor(unpack(globalData.colorTile))
  -- rectBack:setFillColor(math.random(),math.random(),math.random())

  -- grp[3]
  local tileFontSize = dim.tileFontSize
  if string.len(letter) > 3 then
    tileFontSize = tileFontSize * 0.5
  elseif string.len(letter) > 1 then
    tileFontSize = tileFontSize * 0.666
  end
  -- tried a highlight on the letter; can't see it against ivory background
  -- local textHighlight = display.newText(grp, letter, -(dim.Q / 30), -(dim.Q / 30), const.FONTS.ACME, tileFontSize)
  -- textHighlight:setFillColor(unpack(const.COLORS.white))

  local textLetter = display.newText(grp, letter, 0, 0, const.FONTS.ACME, tileFontSize)
  textLetter:setFillColor(unpack(const.COLORS.Black))

  -- grp[4]
  -- makes the grid harder to scan
  -- if string.len(letter) == 1 and const.SCRABBLE_SCORES[letter] then
  --   local textScore = display.newText(grp, tostring(const.SCRABBLE_SCORES[letter]), dim.Q / 3, dim.Q / 3, const.FONTS.ACME, tileFontSize / 3)
  --   textScore:setFillColor(unpack(const.COLORS.Black))
  -- end

  return grp
end

function Tile.createLittleGraphics(parent, x, y, txt, color)
  local grp = Tile.createGraphics(parent, x, y, txt)
  grp:scale(0.5, 0.5)
  if color then
    grp[2]:setFillColor(unpack(color))
  end
  return grp
end

function Tile:depress()
  local dim = globalData.dim

  local rectShadow = self.grp[1]
  rectShadow.x = 0
  rectShadow.y = 0
  local rectBack = self.grp[2]
  rectBack.x = dim.offset3D
  rectBack.y = dim.offset3D
  local textLetter = self.grp[3]
  textLetter.x = dim.offset3D
  textLetter.y = dim.offset3D
end

function Tile:undepress()
  local dim = globalData.dim

  local rectShadow = self.grp[1]
  rectShadow.x = dim.offset3D
  rectShadow.y = dim.offset3D
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

function Tile:select(who)
  who = who or 'HUMAN'
  if who == 'HUMAN' then
    self.grp[2]:setFillColor(unpack(globalData.colorSelected))
  elseif who == 'ROBOTO' then
    self.grp[2]:setFillColor(unpack(globalData.colorRoboto))
  else
    self.grp[2]:setFillColor(unpack(const.COLORS.white))
  end
  self.selected = true
  self:depress()
end

function Tile:deselect()
  self.selected = false
  self.grp[2]:setFillColor(unpack(globalData.colorTile))
  self:undepress()
end

function Tile:delete()
  -- When you remove a display object, event listeners that are attached to it — tap and touch listeners,
  -- for example — are also freed from memory.
  -- self.grp:removeEventListener('touch', self)
  if self.grp then
    display.remove(self.grp)
    self.grp = nil
  end
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
    time = 1000,
    transition = easing.outQuad,
  })
end

function Tile:flyAway(n, wordLength)
  local dim = globalData.dim

  self.grp:toFront()

  transition.moveTo(self.grp, {
    -- x = (dim.halfQ + (dim.Q * (n-1))) + ((display.actualContentWidth / 2) - ((dim.Q * wordLength) / 2)),
    x = dim.quarterQ + (dim.halfQ * (n-1)) + ((display.actualContentWidth / 2) - ((dim.halfQ * wordLength) / 2)),
    y = dim.wordbarY,
    time = 2000,
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
    time = 2000,
    transition = easing.linear,
    onComplete = function() self:delete() end,
  })
end

return Tile
