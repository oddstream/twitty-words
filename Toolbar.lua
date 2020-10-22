-- Toolbar.lua

local composer = require 'composer'
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

local Toolbar = {}
Toolbar.__index = Toolbar

function Toolbar.new(o)
  assert(o) -- need to be called with an initializing object
  assert(o.group)

  -- assert(self==Toolbar)
  setmetatable(o, Toolbar)

  local dim = _G.DIMENSIONS

  local height = dim.toolBarHeight
  local halfHeight = height / 2

  o.rect = display.newRect(o.group, display.contentCenterX, halfHeight, display.contentWidth, height)
  o.rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  -- o.left = display.newText(o.group, '', fontSize2, display.contentHeight - halfHeight, _G.BOLD_FONT, fontSize)
  -- o.left:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.left = widget.newButton({
    x = dim.Q50,
    y = halfHeight,
    onRelease = function()
      _G.grid:jumble()
    end,
    label = '',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'left',
    font = _G.TILE_FONT,
    fontSize = dim.Q50,
    textOnly = true,
  })
  o.group:insert(o.left)

  o.center = display.newText(o.group, '', display.contentCenterX, halfHeight, _G.TILE_FONT, dim.Q50)
  o.center:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  -- o.right = display.newText(o.group, '', display.contentWidth - fontSize2, display.contentHeight - halfHeight, _G.BOLD_FONT, fontSize)
  -- o.right:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.right = widget.newButton({
    x = display.contentWidth - dim.Q50,
    y = halfHeight,
    onRelease = function()
      composer.showOverlay('FoundWords')
    end,
    label = '',
    labelColor = { default=_G.MUST_COLORS.uiforeground, over=_G.MUST_COLORS.uicontrol },
    labelAlign = 'right',
    font = _G.TILE_FONT,
    fontSize = dim.Q50,
    textOnly = true,
  })
  o.group:insert(o.right)

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

function Toolbar:set(pos, s)
  self[pos].text = s or ''
end

function Toolbar:setLeft(s)
  -- self:set('left', s)
  self.left:setLabel(s)
end

function Toolbar:setCenter(s)
  self:set('center', s)
end

function Toolbar:setRight(s)
  -- self:set('right', s)
  self.right:setLabel(s)
end

return Toolbar