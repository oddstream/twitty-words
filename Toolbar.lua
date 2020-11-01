-- Toolbar.lua

local composer = require 'composer'

local Tappy = require 'Tappy'
local Tile = require 'Tile'

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
  -- rect = nil,
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

  -- o.rect = display.newRect(_G.MUST_GROUPS.ui, display.contentCenterX, halfHeight, display.actualContentWidth, height)
  -- o.rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  o.left = Tappy.new(_G.MUST_GROUPS.ui, dim.halfQ, halfHeight, function() _G.grid:jumble() end)

--[[
  o.center = display.newText(_G.MUST_GROUPS.ui, '', display.contentCenterX, halfHeight, _G.TILE_FONT, dim.halfQ)
  -- o.center:setFillColor(unpack(_G.MUST_COLORS.uiforeground))
  o.center:setFillColor(unpack(_G.MUST_COLORS.black))
]]
  o.center = display.newGroup()
  -- o.center.x = display.contentCenterX
  -- o.center.y = halfHeight
  -- o.center.anchorX = 0.5
  _G.MUST_GROUPS.ui:insert(o.center)

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

local function _createTile(group, x, y, txt)
  local grp = Tile.createGraphics(x, y, txt)
  group:insert(grp)
  grp:scale(0.5, 0.5)
  return grp
end

--[[
function Toolbar:set(pos, s)
  self[pos].text = s or ''
end
]]

function Toolbar:setLeft(s)
  -- self:set('left', s)
  self.left:setLabel(s)
end

function Toolbar:setCenter(s)
--[[
  self:set('center', s)
]]
  local dim = _G.DIMENSIONS

  while self.center.numChildren > 0 do
    self.center[1]:removeSelf()
  end
  if s then
    local x = dim.halfQ
    for i=1, string.len(s) do
      local tile = _createTile(self.center, x, dim.halfQ, string.sub(s, i, i))
      self.center:insert(tile)
      x = x + dim.halfQ
    end
    -- the first tile is dim.halfQ over to the right
    self.center.x = display.contentCenterX - (string.len(s) * dim.halfQ / 2) - (dim.halfQ / 2)
  end
end

function Toolbar:setRight(s)
  -- self:set('right', s)
  self.right:setLabel(s)
end

return Toolbar
