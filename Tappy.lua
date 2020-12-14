-- Tappy.lua

local const = require 'constants'
local globalData = require 'globalData'
local Util = require 'Util'
local Ivory = require 'Ivory'

local Tappy = {}
Tappy.__index = Tappy

function Tappy.new(group, x, y, cmd, label, description)

  local o = {}
  setmetatable(o, Tappy)

  o.cmd = cmd
  o.enabled = true

  o.iv = Ivory.new({
    parent = group,
    x = x,
    y = y,
    text = label,
    description = description,
    color = globalData.colorTappy,
  })

  -- removed the tap listener below; creates false hit when coming back from FoundWords
  -- o.grp:addEventListener('tap', o)
  o.iv:addTouchListener(o)

  return o
end
--[[
function Tappy:_createGraphics(parent, x, y, label, description)
  local dim = globalData.dim
  local grp = Tile.createGraphics(parent, x, y, label)


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
      font = const.FONTS.ACME,
      fontSize = dim.halfQ / 3,
    })
    txt:setFillColor(unpack(const.COLORS.Black))
  else
    self.letterNormalY = 0
    self.letterDepressedY = dim.offset3D
  end

  return grp
end
]]

--[[
function Tappy:setLabel(label)
  local dim = globalData.dim

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
]]

function Tappy:enable(enabled)
  assert(type(enabled)=='boolean')

  self.enabled = enabled

  local color = enabled and const.COLORS.Black or const.COLORS.Gray
  self.iv:setTextColor(color)
end

function Tappy:addTouchListener()
  self.iv:addTouchListener(self)
end

function Tappy:removeTouchListener()
  self.iv:removeTouchListener(self)
end

-- function Tappy:tap(event)
--   self.cmd()
--   return true
-- end

function Tappy:touch(event)
  -- event.target is self.grp

  if event.phase == 'began' then
    -- trace('touch began', event.x, event.y, self.letter)

    display.getCurrentStage():setFocus(event.target)  -- stop dragging the stage all over the place
    self.iv:depress()

  elseif event.phase == 'moved' then
    -- trace('touch moved', event.x, event.y, self.letter)

  elseif event.phase == 'ended' then
    -- trace('touch ended', event.x, event.y, self.letter)

    display.getCurrentStage():setFocus(nil)
    self.iv:undepress()

    if self.enabled then -- nil and false are false
      local sceneX, sceneY = self.iv:localToContent()
      -- or use object.contentBounds (returns a table with 4 values)
      if Util.pointInCircle(event.x, event.y, sceneX, sceneY, globalData.dim.halfQ) then
        self.cmd()
      end
    end

  elseif event.phase == 'cancelled' then
    -- trace('touch cancelled', event.x, event.y, self.letter)

    display.getCurrentStage():setFocus(nil)
    self.iv:undepress()

  end

  return true
end

function Tappy:delete()
  self.iv:delete()
  self.iv = nil
end

return Tappy
