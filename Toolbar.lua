-- Toolbar.lua

local globalData = require 'globalData'

local Tappy = require 'Tappy'
local Util = require 'Util'

local Tappies = {
  {element='shuffle', label='Sh', subtitle='SHUFFLE', command=function() globalData.grid:shuffle() end},
  {element='hint', label='Hi', subtitle='HINT', command=function() globalData.grid:hint() end},
  {element='undo', label='Un', subtitle='UNDO', command=function() globalData.grid:undo() end},
  {element='result', label='Wo', subtitle='WORDS', command=function() globalData.grid:showFoundWords() end},
}

local Toolbar = {}
Toolbar.__index = Toolbar

function Toolbar.new()
  local o = {}

  -- assert(self==Toolbar)
  setmetatable(o, Toolbar)

  local dim = globalData.dim

  o.rect = display.newRect(globalData.uiGroup, dim.toolbarX, dim.toolbarY, dim.toolbarWidth, dim.toolbarHeight)
  o.rect:setFillColor(0.1,0.1,0.1)
  o.rect.alpha = 0.1

  for i=1,#Tappies do
    local tp = Tappies[i]
    o[tp.element] = Tappy.new({
      parent = globalData.uiGroup,
      x = Util.mapValue(i, 1, #Tappies, dim.halfQ, display.actualContentWidth - dim.halfQ),
      y = dim.toolbarY,
      command = tp.command,
      text = tp.label,
      description = tp.subtitle
    })
  end

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
  for i=1,#Tappies do
    local tp = Tappies[i]
    self[tp.element]:removeTouchListener()
  end
end

function Toolbar:resumeTouch()
  for i=1,#Tappies do
    local tp = Tappies[i]
    self[tp.element]:addTouchListener()
  end
end

return Toolbar
