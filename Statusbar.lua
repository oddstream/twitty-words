-- Statusbar.lua

local Statusbar = {}
Statusbar.__index = Statusbar

function Statusbar.new(o)
  assert(o) -- need to be called with an initializing object
  assert(o.group)

  -- assert(self==Statusbar)
  setmetatable(o, Statusbar)

  local height = _G.DIMENSIONS.statusBarHeight
  local halfHeight = height / 2
  local fontSize = halfHeight

  o.rect = display.newRect(o.group, display.contentCenterX, display.contentHeight - halfHeight, display.contentWidth, height)
  o.rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  o.left = display.newText(o.group, '', fontSize * 2, display.contentHeight - halfHeight, _G.BOLD_FONT, fontSize)
  o.left:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.center = display.newText(o.group, '', display.contentCenterX, display.contentHeight - halfHeight, _G.BOLD_FONT, fontSize)
  o.center:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.right = display.newText(o.group, '', display.contentWidth - fontSize * 2, display.contentHeight - halfHeight, _G.BOLD_FONT, fontSize)
  o.right:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  return o
end

function Statusbar:destroy()
  display.remove(self.rect)
  display.remove(self.left)
  display.remove(self.center)
  display.remove(self.right)
end

function Statusbar:setLeft(s)
  if not s then
    self.left.text = ''
  else
    self.left.text = s
  end
end

function Statusbar:setCenter(s)
  if not s then
    self.center.text = ''
  else
    self.center.text = s
  end
end

function Statusbar:setRight(s)
  if not s then
    self.right.text = ''
  else
    self.right.text = s
  end
end

return Statusbar
