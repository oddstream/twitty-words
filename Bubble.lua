-- Bubble.lua

local Bubble = {}
Bubble.__index = Bubble

function Bubble.new(x, y, label)

  local dim = _G.DIMENSIONS

  local o = {}
  setmetatable(o, Bubble)

  o.label = label

  o.grp = display.newGroup()
  _G.TWITTY_GROUPS.grid:insert(o.grp)
  o.grp.x, o.grp.y = x, y

  o.circle = display.newCircle(o.grp, 0, 0,dim.Q / 4)
  o.circle:setFillColor(unpack(_G.TWITTY_COLORS.uibackground))

  o.label = display.newText({
    parent = o.grp,
    text = o.label,
    x = 0,
    y = 0,
    font = _G.ACME,
    fontSize = dim.Q / 4,
    align = 'center',
  })
  o.label:setFillColor(unpack(_G.TWITTY_COLORS.uiforeground))

  return o

end

function Bubble:fadeOut()
  transition.scaleTo(self.grp, {xScale=0.1, yScale=0.1, time=_G.FLIGHT_TIME / 2, onComplete=function() self.grp:removeSelf() end})
end

function Bubble:flyTo(x, y)
  transition.moveTo(self.grp, {x=x, y=y, time=_G.FLIGHT_TIME, transition=easing.outQuart, onComplete=function() self.grp:removeSelf() end})
end

return Bubble
