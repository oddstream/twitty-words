-- Toolbar.lua

local composer = require 'composer'

local Tappy = require 'Tappy'

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

local Toolbar = {
  rect = nil,
  left = nil,
  center = nil,
  right = nil,
}
Toolbar.__index = Toolbar

function Toolbar.new()
  local o = {}

  -- assert(self==Toolbar)
  setmetatable(o, Toolbar)

  local dim = _G.DIMENSIONS

  local height = dim.toolBarHeight
  local halfHeight = height / 2

  o.rect = display.newRect(_G.MUST_GROUPS.ui, display.contentCenterX, halfHeight, display.contentWidth, height)
  o.rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  o.left = Tappy.new(_G.MUST_GROUPS.ui, dim.halfQ, halfHeight, function() _G.grid:jumble() end)

  o.center = display.newText(_G.MUST_GROUPS.ui, '', display.contentCenterX, halfHeight, _G.TILE_FONT, dim.halfQ)
  o.center:setFillColor(unpack(_G.MUST_COLORS.uiforeground))

  o.right = Tappy.new(_G.MUST_GROUPS.ui, display.actualContentWidth - dim.halfQ, halfHeight, function()
    _G.grid:pauseCountdown()
    composer.showOverlay('FoundWords', {effect='slideRight'})
  end)

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
