-- Statusbar.lua

local Statusbar = {}
Statusbar.__index = Statusbar

function Statusbar.new()
  local o = {}

  -- assert(self==Statusbar)
  setmetatable(o, Statusbar)

  local dim = _G.DIMENSIONS
  local fontSize = dim.Q / 3
  local halfFontSize = fontSize / 2

  o.rect = display.newRect(_G.MUST_GROUPS.ui, dim.statusbarX, dim.statusbarY, dim.statusbarWidth, dim.statusbarHeight)
  o.rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  o.left = display.newText(_G.MUST_GROUPS.ui, 'left', dim.marginX + halfFontSize, dim.statusbarY, _G.TILE_FONT, fontSize)
  o.left:setFillColor(unpack(_G.MUST_COLORS.uiforeground))
  o.left.anchorX = 0

  o.center = display.newText(_G.MUST_GROUPS.ui, 'center', dim.statusbarX, dim.statusbarY, _G.TILE_FONT, fontSize)
  o.center:setFillColor(unpack(_G.MUST_COLORS.uiforeground))
  o.center.anchorX = 0.5

  o.right = display.newText(_G.MUST_GROUPS.ui, 'right', dim.statusbarWidth - halfFontSize, dim.statusbarY, _G.TILE_FONT, fontSize)
  o.right:setFillColor(unpack(_G.MUST_COLORS.uiforeground))
  o.right.anchorX = 1

  return o
end

--[[
function Toolbar:destroy()
  display.remove(self.rect)
  display.remove(self.left)
  display.remove(self.center)
  display.remove(self.right)
end
]]

function Statusbar:set(pos, s)
  self[pos].text = s or ''
end

function Statusbar:setLeft(s)
  self:set('left', s)
end

function Statusbar:setCenter(s)
  self:set('center', s)
end

function Statusbar:setRight(s)
  self:set('right', s)
end

return Statusbar
