-- Wordbar.lua

local Tile = require 'Tile'
local Util = require 'Util'

local Wordbar = {}
Wordbar.__index = Wordbar

function Wordbar.new()
  local o = {}

  -- assert(self==Wordbar)
  setmetatable(o, Wordbar)

  -- o.rect = display.newRect(_G.TWITTY_GROUPS.ui, dim.toolbarX, dim.toolbarY, dim.toolbarWidth, dim.toolbarHeight)
  -- o.rect:setFillColor(unpack(_G.TWITTY_COLORS.uibackground))

  o.center = display.newGroup()
  _G.TWITTY_GROUPS.ui:insert(o.center)

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

local function _createTile(group, x, y, txt)
  local grp = Tile.createGraphics(x, y, txt)
  group:insert(grp)
  grp:scale(0.5, 0.5)
  return grp
end

function Wordbar:setCenter(s)
  -- self:set('center', s)

  local dim = _G.DIMENSIONS

  while self.center.numChildren > 0 do
    self.center[1]:removeSelf()
  end

  -- too slow!
  -- local found = s and Util.isWordInDictionary(s) or false

  if s then
    local x = dim.halfQ
    for i=1, string.len(s) do
      local tile = _createTile(self.center, x, dim.wordbarY, string.sub(s, i, i))
      self.center:insert(tile)
      x = x + dim.halfQ
    end
    -- the first tile is dim.halfQ over to the right
    self.center.x = display.contentCenterX - (string.len(s) * dim.halfQ / 2) - (dim.halfQ / 2)
  end

end

return Wordbar
