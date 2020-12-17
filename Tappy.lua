-- Tappy.lua

local const = require 'constants'
local globalData = require 'globalData'
local Util = require 'Util'
local Ivory = require 'Ivory'

local Tappy = {}
Tappy.__index = Tappy

function Tappy.new(params)

  local o = {}
  setmetatable(o, Tappy)

  params.color = params.color or globalData.colorTappy
  o.command = params.command  -- save this
  o.enabled = true  -- add our own feature

  o.iv = Ivory.new(params)  -- pass through the params; command will be ignored

  -- removed the tap listener because it creates false hit when coming back from FoundWords
  o.iv:addTouchListener(o)

  return o
end

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
        self.command()
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
