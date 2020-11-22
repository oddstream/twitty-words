-- Tappy.lua

local Tile = require 'Tile'

local Tappy = {}
Tappy.__index = Tappy

function Tappy.new(group, x, y, cmd, label, description)

  local o = {}
  setmetatable(o, Tappy)

  o.group = group
  o.cmd = cmd
  o.description = description
  o.label = label

  o.grp = o:_createGraphics(x, y, o.label, o.description)
  o.grp[2]:setFillColor(unpack(_G.TWITTY_COLORS.tappy))
  o.group:insert(o.grp)

  -- removed the tap listener below; creates false hit when coming back from FoundWords
  -- o.grp:addEventListener('tap', o)
  o.grp:addEventListener('touch', o)

  return o
end

function Tappy:_createGraphics(x, y, label, description)
  local dim = _G.DIMENSIONS
  local grp = Tile.createGraphics(x, y, label)

  if description then
    self.letterNormalY = -(dim.Q / 8)
    self.letterDepressedY = self.letterNormalY + dim.offset3D
    self.descriptionNormalY = dim.Q / 3
    self.descriptionDepressedY = self.descriptionNormalY + dim.offset3D

    grp[3].y = self.letterNormalY
    local txt = display.newText({
      parent = grp,
      text = description,
      x = 0,
      y = self.descriptionNormalY,
      font = _G.ACME,
      fontSize = dim.halfQ / 3,
    })
    txt:setFillColor(unpack(_G.TWITTY_COLORS.black))
  else
    self.letterNormalY = 0
    self.letterDepressedY = dim.offset3D
  end

  return grp
end

function Tappy:setLabel(label)
  local dim = _G.DIMENSIONS

  if self.grp and self.grp[3] and self.grp[3].text then  -- timer may have elapsed
    local item = self.grp[3]
    item.text = label
    if label then
      -- To change the font size of a text object after it has been created, set the object.size property, not object.fontSize.
      if string.len(label) > 3 then
        item.size = dim.tileFontSize * 0.5
      elseif string.len(label) > 1 then
        item.size = dim.tileFontSize * 0.666
      else
        item.size = dim.tileFontSize
      end
    end
  end
end

function Tappy:enable()
  if self.grp and self.grp[3] then
    self.disabled = false
    self.grp[3]:setFillColor(unpack(_G.TWITTY_COLORS.black))
    if self.description then
      self.grp[4]:setFillColor(unpack(_G.TWITTY_COLORS.black))
    end
  end
end

function Tappy:disable()
  if self.grp and self.grp[3] then
    self.disabled = true
    self.grp[3]:setFillColor(unpack(_G.TWITTY_COLORS.gray))
    if self.description then
      self.grp[4]:setFillColor(unpack(_G.TWITTY_COLORS.gray))
    end
  end
end

function Tappy:depress()
  -- this is the same as Tile:depress, with description
  local dim = _G.DIMENSIONS

  local rectShadow = self.grp[1]
  rectShadow.x = 0
  rectShadow.y = 0

  local rectBack = self.grp[2]
  rectBack.x = dim.offset3D
  rectBack.y = dim.offset3D

  local textLetter = self.grp[3]
  textLetter.x = dim.offset3D
  textLetter.y = self.letterDepressedY

  if self.description then
    local textDesc = self.grp[4]
    textDesc.x = dim.offset3D
    textDesc.y = self.descriptionDepressedY
  end
end

function Tappy:undepress()
  -- this is the same as Tile:undepress, with description
  local dim = _G.DIMENSIONS

  local rectShadow = self.grp[1]
  rectShadow.x = dim.offset3D
  rectShadow.y = dim.offset3D

  local rectBack = self.grp[2]
  rectBack.x = 0
  rectBack.y = 0

  local textLetter = self.grp[3]
  textLetter.x = 0
  textLetter.y = self.letterNormalY

  if self.description then
    local textDesc = self.grp[4]
    textDesc.x = 0
    textDesc.y = self.descriptionNormalY
  end
end

-- function Tappy:tap(event)
--   self.cmd()
--   return true
-- end

function Tappy:touch(event)
  -- event.target is self.grp

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y, self.letter)
    display.getCurrentStage():setFocus(event.target)
    self:depress()

  elseif event.phase == 'moved' then
    -- trace('touch moved', event.x, event.y, self.letter)

  elseif event.phase == 'ended' then
    -- trace('touch ended', event.x, event.y, self.letter)
    display.getCurrentStage():setFocus(nil)
    self:undepress()
    if not self.disabled then -- nil and false are false
      self.cmd()
    end

  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.y, self.letter)
    display.getCurrentStage():setFocus(nil)
    self:undepress()
  end

  return true
end

function Tappy:delete()
  -- When you remove a display object, event listeners that are attached to it — tap and touch listeners,
  -- for example — are also freed from memory.
  -- self.grp:removeEventListener('touch', self)
  display.remove(self.grp)
  self.grp = nil
end

return Tappy
