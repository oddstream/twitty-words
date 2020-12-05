-- Wordbar.lua

local globalData = require 'globalData'

local Tile = require 'Tile'

local Wordbar = {}
Wordbar.__index = Wordbar

function Wordbar.new()
  local o = {}

  -- assert(self==Wordbar)
  setmetatable(o, Wordbar)

  -- o.rect = display.newRect(globalData.uiGroup, dim.toolbarX, dim.toolbarY, dim.toolbarWidth, dim.toolbarHeight)
  -- o.rect:setFillColor(unpack(const.COLORS.uibackground))

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
      local tile = Tile.createLittleGraphics(self.center, x, dim.wordbarY, string.sub(s, i, i))
      self.center:insert(tile)
      x = x + dim.halfQ
    end
    -- the first tile is dim.halfQ over to the right
    self.center.x = display.contentCenterX - (string.len(s) * dim.quarterQ) - dim.quarterQ
  end

end

return Wordbar
