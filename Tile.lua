-- Tile.lua

local const = require 'constants'
local globalData = require 'globalData'

local Ivory = require 'Ivory'

local Tile = {}
Tile.__index = Tile

function Tile.new(slot, letter)

  local o = {}
  setmetatable(o, Tile)

  o.slot = slot

  o.letter = letter

  o.iv = Ivory.new({
    parent = globalData.gridGroup,
    x = slot.center.x,
    y = slot.center.y,
    text = o.letter,
  })

  -- don't add event listers here, as tiles are also used for displaying found words and high scores

  o.selected = false

  return o
end

function Tile:addTouchListener()
  self.iv:addTouchListener(self)
end

function Tile:removeTouchListener()
  self.iv:removeTouchListener(self)
end

function Tile:depress()
  self.iv:depress()
end

function Tile:undepress()
  self.iv:undepress()
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
    self.iv:setBackColor(globalData.colorSelected)
  elseif who == 'ROBOTO' then
    self.iv:setBackColor(globalData.colorRoboto)
  else
    self.iv:setBackColor(const.COLORS.white)
  end
  self.selected = true
  self:depress()
end

function Tile:deselect()
  self.selected = false
  self.iv:setBackColor(globalData.colorTile)
  self:undepress()
end

function Tile:delete()
  -- When you remove a display object, event listeners that are attached to it — tap and touch listeners,
  -- for example — are also freed from memory.
  -- self.grp:removeEventListener('touch', self)
  if self.iv then
    self.iv:delete()
    self.iv = nil
  end
end

function Tile:shake()
  self.iv:shake()
end

function Tile:elevate()
  self.iv:elevate()
end

function Tile:settle()
  self.iv:moveTo(self.slot.center.x, self.slot.center.y)
end

function Tile:flyAway(n, wordLength)
  local dim = globalData.dim

  self.iv:toFront()

  self.iv:moveTo(
    dim.quarterQ + (dim.halfQ * (n-1)) + ((display.actualContentWidth / 2) - ((dim.halfQ * wordLength) / 2)),
    dim.wordbarY,
    2000
  )
  self.iv:shrink()
  -- TODO delete Ivory
end

return Tile
