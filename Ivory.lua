-- Ivory.lua

-- the graphical portion of a tile

local const = require 'constants'
local globalData = require 'globalData'

local Ivory = {}
Ivory.__index = Ivory

function Ivory.new(params)
  local dim = globalData.dim

  local o = {}
  setmetatable(o, Ivory)

  o.grp = display.newGroup()
  o.grp.x = params.x or 0
  o.grp.y = params.y or 0
  params.parent:insert(o.grp)

  if params.scale then
    o.grp:scale(params.scale, params.scale)
  end

  o.enabled = true

  params.text = params.text or ''
  params.color = params.color or globalData.colorTile

  local radius = dim.Q / 15

  -- grp[1]
  o.rectShadow = display.newRoundedRect(o.grp, dim.offset3D, dim.offset3D, dim.size3D, dim.size3D, radius)
  o.rectShadow:setFillColor(unpack(const.COLORS.shadow))

  -- grp[2]
  o.rectBack = display.newRoundedRect(o.grp, 0, 0, dim.size3D, dim.size3D, radius)
  -- if alpha == 0, we don't get tap events
  -- set fill color AFTER applying paint
  o.rectBack:setFillColor(unpack(params.color))
  -- rectBack:setFillColor(math.random(),math.random(),math.random())

  -- grp[3]
  local tileFontSize = dim.tileFontSize
  if string.len(params.text) > 3 then
    tileFontSize = tileFontSize * 0.5
  elseif string.len(params.text) > 1 then
    tileFontSize = tileFontSize * 0.666
  end
  -- tried a highlight on the letter; can't see it against ivory background
  -- local textHighlight = display.newText(grp, letter, -(dim.Q / 30), -(dim.Q / 30), const.FONTS.ACME, tileFontSize)
  -- textHighlight:setFillColor(unpack(const.COLORS.white))

  o.textLetter = display.newText(o.grp, params.text, 0, 0, const.FONTS.ACME, tileFontSize)
  o.textLetter:setFillColor(unpack(const.COLORS.Black))

  if params.description then
    o.letterNormalY = -(dim.Q / 8)
    o.letterDepressedY = o.letterNormalY + dim.offset3D
    o.descriptionNormalY = dim.Q / 3
    o.descriptionDepressedY = o.descriptionNormalY + dim.offset3D

    o.textLetter.y = o.letterNormalY  -- move the letter up a bit to make room

    o.textDescription = display.newText({
      parent = o.grp,
      text = params.description,
      x = 0,
      y = o.descriptionNormalY,
      font = const.FONTS.ACME,
      fontSize = dim.halfQ / 3,
    })
    o.textDescription:setFillColor(unpack(const.COLORS.Black))
  else
    o.letterNormalY = 0
    o.letterDepressedY = dim.offset3D
  end

  return o

end

function Ivory:localToContent()
  return self.rectBack:localToContent(0,0)
end

function Ivory:addTouchListener(tbl)
  if not self.grp then return end
  self.grp:addEventListener('touch', tbl)
end

function Ivory:removeTouchListener(tbl)
  if not self.grp then return end
  self.grp:removeEventListener('touch', tbl)
end

function Ivory:setTextColor(color)
  if not self.grp then return end
  self.textLetter:setFillColor(unpack(color))
  if self.textDescription then
    self.textDescription:setFillColor(unpack(color))
  end
end

function Ivory:setBackColor(color)
  if not self.grp then return end
  self.rectBack:setFillColor(unpack(color))
end

function Ivory:shake()
  if not self.grp then return end
  -- trace('shaking', tostring(self))
  transition.to(self.grp, {time=50, transition=easing.continuousLoop, x=self.grp.x + 10})
  transition.to(self.grp, {delay=50, time=50, transition=easing.continuousLoop, x=self.grp.x - 10})
end

function Ivory:depress()
  local dim = globalData.dim

  if not self.grp then return end

  self.rectShadow.x = 0
  self.rectShadow.y = 0
  self.rectBack.x = dim.offset3D
  self.rectBack.y = dim.offset3D
  self.textLetter.x = dim.offset3D
  self.textLetter.y = self.letterDepressedY
  if self.textDescription then
    self.textDescription.x = dim.offset3D
    self.textDescription.y = self.descriptionDepressedY
  end

end

function Ivory:undepress()
  local dim = globalData.dim

  if not self.grp then return end

  self.rectShadow.x = dim.offset3D
  self.rectShadow.y = dim.offset3D
  self.rectBack.x = 0
  self.rectBack.y = 0
  self.textLetter.x = 0
  self.textLetter.y = self.letterNormalY
  if self.textDescription then
    self.textDescription.x = 0
    self.textDescription.y = self.descriptionNormalY
  end

end

function Ivory:toFront()
  if not self.grp then return end
  self.grp:toFront()
end

function Ivory:elevate()
  if not self.grp then return end
  self.grp.y = -(display.contentHeight / 2)
end

function Ivory:moveTo(x, y, time)
  if not self.grp then return end

  time = time or 1000
  transition.moveTo(self.grp, {
    x = x,
    y = y,
    time = time,
    transition = easing.outQuad,
  })
end

function Ivory:shrink(time)
  if not self.grp then return end

  time = time or 2000
  transition.scaleTo(self.grp, {
    xScale = 0.5,
    yScale = 0.5,
    time = time,
    transition = easing.linear,
    onComplete = function() self:delete() end,
  })
end

function Ivory:flyAway(n, wordLength)
  local dim = globalData.dim

  self.grp:toFront()
  self:moveTo(dim.quarterQ + (dim.halfQ * (n-1)) + ((display.actualContentWidth / 2) - ((dim.halfQ * wordLength) / 2)), dim.wordbarY, 2000)
  self:shrink()
end

function Ivory:delete()
  -- When you remove a display object, event listeners that are attached to it — tap and touch listeners,
  -- for example — are also freed from memory.
  if not self.grp then return end
  self.grp:removeSelf()
  self.grp = nil
end

return Ivory
