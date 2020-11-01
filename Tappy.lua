-- Tappy.lua

local Tile = require 'Tile'

local Tappy = {
  group = nil,
  label = nil,
  cmd = nil,  -- function run when tapped
  grp = nil,  -- group of graphic objects
}
Tappy.__index = Tappy

function Tappy.new(group, x, y, cmd)

  local o = {}
  setmetatable(o, Tappy)

  o.group = group
  o.cmd = cmd
  o.label = ''

  o.grp = o.createGraphics(x, y, o.label)
  o.group:insert(o.grp)

  -- removed the tap listener below; creates false hit when coming back from FoundWords
  -- o.grp:addEventListener('tap', o)
  o.grp:addEventListener('touch', o)

  return o
end

function Tappy.createGraphics(x, y, label)
  return Tile.createGraphics(x, y, label)
end

function Tappy:setLabel(label)
  local dim = _G.DIMENSIONS

  if self.grp and self.grp[3].text then  -- timer may have elapsed
    self.grp[3].text = label
    if label then
      -- To change the font size of a text object after it has been created, set the object.size property, not object.fontSize.
      if string.len(label) == 1 then
        self.grp[3].size = dim.tileFontSize
      else
        self.grp[3].size = dim.tileFontSize * 0.666
      end
    end
  end
end

function Tappy:depress()
  -- TODO this is the same as Tile:depress
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

function Tappy:undepress()
  -- TODO this is the same as Tile:undepress
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
    self.cmd()

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
