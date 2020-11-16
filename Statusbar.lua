-- Statusbar.lua

local composer = require 'composer'
local widget = require 'widget'

local Util = require 'Util'

local Statusbar = {}
Statusbar.__index = Statusbar

function Statusbar.new()
  local o = {}

  setmetatable(o, Statusbar)

  local dim = _G.DIMENSIONS
  local fontSize = dim.Q / 3
  local halfFontSize = fontSize / 2

  o.rect = display.newRect(_G.TWITTY_GROUPS.ui, dim.statusbarX, dim.statusbarY, dim.statusbarWidth, dim.statusbarHeight)
  o.rect:setFillColor(unpack(_G.TWITTY_COLORS.uibackground))

  -- o.left = display.newText(_G.TWITTY_GROUPS.ui, '🦝', halfFontSize, dim.statusbarY, _G.ACME, fontSize)
  -- o.left:setFillColor(unpack(_G.TWITTY_COLORS.uiforeground))
  -- o.left.anchorX = 0
  o.left = widget.newButton({
    x = halfFontSize,
    y = dim.statusbarY,
    onRelease = function()
      Util.sound('ui')
      _G.grid:cancelCountdown()
      _G.grid:deleteTiles()
      composer.gotoScene('ModeMenu')
    end,
    label = '☰',
    labelColor = { default=_G.TWITTY_COLORS.uiforeground, over=_G.TWITTY_COLORS.uicontrol },
    labelAlign = 'left',
    font = _G.ACME,
    fontSize = fontSize,
    textOnly = true,
  })
  o.left.anchorX = 0
  _G.TWITTY_GROUPS.ui:insert(o.left)

  o.center = display.newText(_G.TWITTY_GROUPS.ui, '🦝', dim.statusbarX, dim.statusbarY, _G.ACME, fontSize)
  o.center:setFillColor(unpack(_G.TWITTY_COLORS.uiforeground))
  o.center.anchorX = 0.5

  o.right = display.newText(_G.TWITTY_GROUPS.ui, '🦝', dim.statusbarWidth - halfFontSize, dim.statusbarY, _G.ACME, fontSize)
  o.right:setFillColor(unpack(_G.TWITTY_COLORS.uiforeground))
  o.right.anchorX = 1

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

function Statusbar:set(pos, s)
  if self[pos] and self[pos].text then  -- may have timed out and been deleted
    self[pos].text = s or ''
  end
end

function Statusbar:setLeft(s)
  -- self:set('left', s)
  if self.left then
    self.left:setLabel(s)
  end
end

function Statusbar:setCenter(s)
  self:set('center', s)
end

function Statusbar:setRight(s)
  self:set('right', s)
end

return Statusbar
