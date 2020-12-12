-- Statusbar.lua

local composer = require 'composer'
local widget = require 'widget'

local const = require 'constants'
local globalData = require 'globalData'

local Util = require 'Util'

local Statusbar = {}
Statusbar.__index = Statusbar

function Statusbar.new()
  local o = {}

  setmetatable(o, Statusbar)

  local dim = globalData.dim
  local fontSize = dim.Q / 3
  local halfFontSize = fontSize / 2

  o.rect = display.newRect(globalData.uiGroup, dim.statusbarX, dim.statusbarY, dim.statusbarWidth, dim.statusbarHeight)
  o.rect:setFillColor(unpack(const.COLORS.uibackground))

  -- o.left = display.newText(globalData.uiGroup, '🦝', halfFontSize, dim.statusbarY, const.FONTS.ACME, fontSize)
  -- o.left:setFillColor(unpack(const.COLORS.uiforeground))
  -- o.left.anchorX = 0
  o.left = widget.newButton({
    x = halfFontSize,
    y = dim.statusbarY,
    onRelease = function()
      Util.sound('ui')
      if #globalData.grid.humanFoundWords == 0 then
        globalData.grid:cancelGame()
        composer.gotoScene('ModeMenu', {effect='slideRight'})
      else
        Util.showAlert('Are you sure', 'Abandon this game?', {'Yes','No'}, function(event)
          if event.index == 1 then
            globalData.grid:cancelGame()
            composer.gotoScene('ModeMenu', {effect='slideRight'})
          end
        end)
      end
    end,
    label = '☰',
    labelColor = { default=const.COLORS.uiforeground, over=const.COLORS.uicontrol },
    labelAlign = 'left',
    font = const.FONTS.ACME,
    fontSize = fontSize,
    textOnly = true,
  })
  o.left.anchorX = 0
  globalData.uiGroup:insert(o.left)

  -- could maybe make this a button, tap shows FoundWords scene
  -- const.FONTS.ROBOTO_BOLD didn't display raccoon glyph on phone
  o.center = display.newText(globalData.uiGroup, '🦝', dim.statusbarX, dim.statusbarY, const.FONTS.ACME, fontSize)
  o.center:setFillColor(unpack(const.COLORS.uiforeground))
  o.center.anchorX = 0.5

  o.right = display.newText(globalData.uiGroup, '🦝', dim.statusbarWidth - halfFontSize, dim.statusbarY, const.FONTS.ACME, fontSize)
  o.right:setFillColor(unpack(const.COLORS.uiforeground))
  o.right.anchorX = 1

  -- o.right = widget.newButton({
  --   x = dim.statusbarWidth - halfFontSize,
  --   y = dim.statusbarY,
  --   onRelease = function()
  --     Util.sound('ui')
  --     Public.showLeaderboard()
  --   end,
  --   label = '...',  -- raccoon looks clunky on Chromebook '🦝'
  --   labelColor = { default=const.COLORS.uiforeground, over=const.COLORS.uicontrol },
  --   labelAlign = 'right',
  --   font = const.FONTS.ACME,
  --   fontSize = fontSize,
  --   textOnly = true,
  -- })
  -- o.right.anchorX = 1
  -- globalData.uiGroup:insert(o.right)

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
  -- if self.right then
  --   self.right:setLabel(s)
  -- end
end

return Statusbar
