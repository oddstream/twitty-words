-- Toolbar.lua

local Tappy = require 'Tappy'
local Util = require 'Util'

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
  -- o.rect:setFillColor(unpack(const.COLORS.uibackground))

  o.shuffle = Tappy.new(_G.TWITTY_GROUPS.ui, dim.halfQ, dim.toolbarY, function()
    _G.grid:shuffle()
  end, 'Sh', 'SHUFFLE') -- '🗘' doesn't display on phone, 🔀 doesn't display on Chromebook

  o.hint = Tappy.new(_G.TWITTY_GROUPS.ui, dim.Q + dim.Q, dim.toolbarY, function()
    _G.grid:hint()
  end, 'Hi', 'HINT')  -- 💡

  o.undo = Tappy.new(_G.TWITTY_GROUPS.ui, dim.toolbarX, dim.toolbarY, function()
    _G.grid:undo()
  end, 'Un', 'UNDO') -- '⎌'

  if system.getInfo('environment') == 'simulator' then
    o.robot = Tappy.new(_G.TWITTY_GROUPS.ui, display.actualContentWidth - dim.Q - dim.Q, dim.toolbarY, function()
      local al = Util.showAlert('DEBUG', 'Check dictionaries?', {'Yes','No','Maybe'},
        function(event)
          if 1 == event.index then
            Util.checkDictionaries()
          end
        end)
    end, ' 🐛 ', 'DEBUG')
  end

  o.result = Tappy.new(_G.TWITTY_GROUPS.ui, display.actualContentWidth - dim.halfQ, dim.toolbarY, function()
    _G.grid:showFoundWords()
  end, 'Wo', 'WORDS')  -- make ' ⚖ ' string longer to trick into scaling down glyph size

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

function Toolbar:enable(tappy, enabled)
  if self[tappy] then
    self[tappy]:enable(enabled)
  end
end

function Toolbar:suspendTouch()
  self.shuffle:removeTouchListener()
  self.hint:removeTouchListener()
  self.undo:removeTouchListener()
  self.result:removeTouchListener()
end

function Toolbar:resumeTouch()
  self.shuffle:addTouchListener()
  self.hint:addTouchListener()
  self.undo:addTouchListener()
  self.result:addTouchListener()
end

return Toolbar
