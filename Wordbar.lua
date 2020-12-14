-- Wordbar.lua

local globalData = require 'globalData'

local Ivory = require 'Ivory'

local Wordbar = {}
Wordbar.__index = Wordbar

function Wordbar.new()
  local o = {}

  -- assert(self==Wordbar)
  setmetatable(o, Wordbar)

  do
    local dim = globalData.dim
    o.rect = display.newRect(globalData.uiGroup, dim.wordbarX, dim.wordbarY, dim.wordbarWidth, dim.wordbarHeight)
    o.rect:setFillColor(0.1,0.1,0.1)
    o.rect.alpha = 0.1
  end

  o.center = display.newGroup()
  globalData.uiGroup:insert(o.center)

  return o
end

--[[
function Wordbar:destroy()
  display.remove(self.rect)
  display.remove(self.left)
  display.remove(self.center)
  display.remove(self.right)
end
]]

function Wordbar:setCenter(s)
  -- self:set('center', s)

  local dim = globalData.dim

  if not self.center then -- timed out, object deleted
    return
  end

  if not self.center.numChildren then -- timed out, object deleted
    return
  end

  while self.center.numChildren > 0 do
    self.center[1]:removeSelf()
  end

  -- too slow!
  -- local found = s and Util.isWordInDictionary(s) or false

  if s then
    local x = dim.halfQ
    for i=1, string.len(s) do
      -- Ivory.new creates a grp which it inserts into self.center
      Ivory.new({
        parent = self.center,
        x = x,
        y = dim.wordbarY,
        text = string.sub(s, i, i),
        scale = 0.5,
      })
      x = x + dim.halfQ
    end
    -- the first ivory is dim.halfQ over to the right
    self.center.x = display.contentCenterX - (string.len(s) * dim.quarterQ) - dim.quarterQ
  end

end

return Wordbar
