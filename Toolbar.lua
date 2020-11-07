-- Toolbar.lua

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

local Toolbar = {}
Toolbar.__index = Toolbar

function Toolbar.new()
  local o = {}

  -- assert(self==Toolbar)
  setmetatable(o, Toolbar)

  local dim = _G.DIMENSIONS

  -- o.rect = display.newRect(_G.MUST_GROUPS.ui, dim.toolbarX, dim.toolbarY, dim.toolbarWidth, dim.toolbarHeight)
  -- o.rect:setFillColor(unpack(_G.MUST_COLORS.uibackground))

  o.left = Tappy.new(_G.MUST_GROUPS.ui, dim.halfQ, dim.toolbarY, function()
    _G.grid:shuffle()
  end)
  o.left.grp[2]:setFillColor(unpack(_G.MUST_COLORS.tappy))

  o.undo = Tappy.new(_G.MUST_GROUPS.ui, dim.toolbarX, dim.toolbarY, function()
    _G.grid:undo()
  end)
  o.undo.grp[2]:setFillColor(unpack(_G.MUST_COLORS.tappy))
  o.undo:setLabel('⎌')

  -- o.center = display.newText(_G.MUST_GROUPS.ui, '', dim.toolbarX, dim.toolbarY, _G.TILE_FONT, dim.tileFontSize)
  -- o.center:setFillColor(unpack(_G.MUST_COLORS.black))

  o.right = Tappy.new(_G.MUST_GROUPS.ui, display.actualContentWidth - dim.halfQ, dim.toolbarY, function()
    _G.grid:showFoundWords()
  end)
  o.right.grp[2]:setFillColor(unpack(_G.MUST_COLORS.tappy))

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

-- function Toolbar:setCenter(s)
--   self:set('center', s)
-- end

function Toolbar:setRight(s)
  -- self:set('right', s)
  self.right:setLabel(s)
end

return Toolbar
