-- Titlebar.lua

local Titlebar = {}
Titlebar.__index = Titlebar

function Titlebar.new(o)
  assert(o) -- need to be called with an initializing object
  assert(o.group)

  -- assert(self==Titlebar)
  setmetatable(o, Titlebar)

  local height = _G.DIMENSIONS.titleBarHeight
  local halfHeight = height / 2
  local fontSize = halfHeight
  local fontSize2 = height

  o.rect = display.newRect(o.group, display.contentCenterX, halfHeight, display.contentWidth, height)
  o.rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  o.left = display.newText(o.group, '★', fontSize2, halfHeight, _G.BOLD_FONT, fontSize)
  o.left:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.center = display.newText(o.group, 'Tiles', display.contentCenterX, halfHeight, _G.BOLD_FONT, fontSize)
  o.center:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.right = display.newText(o.group, '?', display.contentWidth - fontSize2, halfHeight, _G.BOLD_FONT, fontSize)
  o.right:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  return o
end

--[[
function Titlebar:destroy()
  display.remove(self.rect)
  display.remove(self.left)
  display.remove(self.center)
  display.remove(self.right)
end
]]

function Titlebar:set(pos, s)
  self[pos].text = s or ''
end

function Titlebar:setLeft(s)
  self:set('left', s)
end

function Titlebar:setCenter(s)
  self:set('center', s)
end

function Titlebar:setRight(s)
  self:set('right', s)
end

return Titlebar