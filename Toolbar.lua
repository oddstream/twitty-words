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

  -- o.rect = display.newRect(_G.TWITTY_GROUPS.ui, dim.toolbarX, dim.toolbarY, dim.toolbarWidth, dim.toolbarHeight)
  -- o.rect:setFillColor(unpack(_G.TWITTY_COLORS.uibackground))

  o.swap = Tappy.new(_G.TWITTY_GROUPS.ui, dim.halfQ, dim.toolbarY, function()
    _G.grid:shuffle()
  end, '⇆', 'SWAP')

  o.hint = Tappy.new(_G.TWITTY_GROUPS.ui, dim.Q + dim.Q, dim.toolbarY, function()
    _G.grid:hint()
  end, ' 💡 ', 'HINT')

  o.undo = Tappy.new(_G.TWITTY_GROUPS.ui, dim.toolbarX, dim.toolbarY, function()
    _G.grid:undo()
  end, '⎌', 'UNDO')

  o.result = Tappy.new(_G.TWITTY_GROUPS.ui, display.actualContentWidth - dim.halfQ, dim.toolbarY, function()
    _G.grid:showFoundWords()
  end, ' ⚖ ', 'RESULT')  -- make string longer to trick into scaling down glyph size

  return o
end

--[[
function Toolbar:destroy()
  display.remove(self.rect)
end
]]

function Toolbar:set(tappy, s)
  if self[tappy] then
    self[tappy]:setLabel(s)
  end
end

function Toolbar:enable(tappy)
  if self[tappy] then
    self[tappy]:enable()
  end
end

function Toolbar:disable(tappy)
  if self[tappy] then
    self[tappy]:disable()
  end
end

return Toolbar
