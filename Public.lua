-- Public.lua

local gpgs = require 'plugin.gpgs.v2'

local Public = {}
Public.__index = Public

--[[
function Public.new()
  local o = {}

  setmetatable(o, Public)
end
]]

local authorizationState = nil

local function initListener(event)
--[[
  event.name
  event.isError
  event.errorMessage
  event.errorCode
]]
  if event.isError then
    native.showAlert(event.name, event.errorMessage, {'OK'})
  end
  native.showAlert(event.name, event.isError, {'OK'})

  initiated = not event.isError
end

local function loginListener(event)
--[[
  event.name
  event.isError
  event.errorMessage
  event.errorCode
  event.phase one of "logged in", "canceled", "logged out"
]]
  if event.isError then
    native.showAlert(event.name, event.errorMessage, {'OK'})
  end
  authorizationState = event.phase

  native.showAlert(event.name, event.phase, {'OK'})
end

function Public.showLeaderboard()
  -- gpgs.init(initListener) -- never gets called, read somewhere it's no longer needed
  gpgs.login({userInitiated=false, listener=loginListener})

  gpgs.logout()
end

function Public.addToLeaderboard()
end

return Public
