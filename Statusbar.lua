-- Statusbar.lua

local widget = require 'widget'

--[[
  varargs
  args count = 0
    use ''
  args count = 1
    string | number
  args count > 1 and type arg1 == string
    string.format(arg1, ...)
    remove first element from argv
    string.format(pattern, unpack(rest of args))

function f1(...)
  -- do not use `arg` name for this variable
  local argv, argc = {...}, select('#', ...)
  for i = 1, argc do
    -- handle argv[i]
end

]]

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
  local fontSize2 = height

  o.rect = display.newRect(o.group, display.contentCenterX, display.contentHeight - halfHeight, display.contentWidth, height)
  o.rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  -- o.left = display.newText(o.group, '', fontSize2, display.contentHeight - halfHeight, _G.BOLD_FONT, fontSize)
  -- o.left:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.left = widget.newButton({
    x = fontSize2,
    y = display.contentHeight - halfHeight,
    onRelease = function()
      _G.grid:jumble()
    end,
    label = 'JUMBLE',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    font = _G.BOLD_FONT,
    fontSize = fontSize,
    textOnly = true,
  })
  o.group:insert(o.left)

  o.center = display.newText(o.group, '', display.contentCenterX, display.contentHeight - halfHeight, _G.BOLD_FONT, fontSize)
  o.center:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.right = display.newText(o.group, '', display.contentWidth - fontSize2, display.contentHeight - halfHeight, _G.BOLD_FONT, fontSize)
  o.right:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  return o
end

--[[
function Statusbar:destroy()
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
  -- self:set('left', s)
  self.left:setLabel(s)
end

function Statusbar:setCenter(s)
  self:set('center', s)
end

function Statusbar:setRight(s)
  self:set('right', s)
end

return Statusbar
