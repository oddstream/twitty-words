-- Bubble.lua

local const = require 'constants'
local globalData = require 'globalData'

local Bubble = {}
Bubble.__index = Bubble

function Bubble.new(x, y, label)

  local dim = globalData.dim

  local o = {}
  setmetatable(o, Bubble)

  o.label = label

  o.grp = display.newGroup()
  globalData.gridGroup:insert(o.grp)
  o.grp.x, o.grp.y = x, y
  o.grp.alpha = 0.75

  o.circle = display.newCircle(o.grp, 0, 0,dim.quarterQ)
  o.circle:setFillColor(unpack(globalData.colorTile))

  local fontSize
  if string.len(o.label) > 3 then -- eg '+100'
    fontSize = dim.Q / 5
  else
    fontSize = dim.Q / 4
  end

  o.text = display.newText({
    parent = o.grp,
    text = o.label,
    x = 0,
    y = 0,
    font = const.FONTS.ACME,
    fontSize = fontSize,
    align = 'center',
  })
  o.text:setFillColor(0,0,0)

  return o

end

function Bubble:fadeOut()
  transition.scaleTo(self.grp, {xScale=0.1, yScale=0.1, time=1000, transition=easing.inQuart, onComplete=function() self.grp:removeSelf() end})
end

function Bubble:flyTo(x, y)
  transition.moveTo(self.grp, {x=x, y=y, time=4000, transition=easing.outQuart, onComplete=function() self.grp:removeSelf() end})
end

return Bubble
