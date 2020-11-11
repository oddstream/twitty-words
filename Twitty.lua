-- Must.lua

local Statusbar = require 'Statusbar'
local Wordbar = require 'Wordbar'
local Toolbar = require 'Toolbar'

local Util = require 'Util'

local composer = require('composer')
local scene = composer.newScene()
local widget = require('widget')

widget.setTheme('widget_theme_android_holo_dark')

--[[
-----------------------------
local profileThreshold = 0
if system.getInfo('environment') == 'simulator' then
  profileThreshold = 1000
end
local Counters = {}
local Names = {}

local function hook ()
  local f = debug.getinfo(2, "f").func
  if Counters[f] == nil then    -- first time `f' is called?
    Counters[f] = 1
    Names[f] = debug.getinfo(2, "Sn")
  else  -- only increment the counter
    Counters[f] = Counters[f] + 1
  end
end

local function getname (func)
  local n = Names[func]
  if n.what == "C" then
    return n.name
  end
  local loc = string.format("[%s]:%s", n.short_src, n.linedefined)
  if n.namewhat ~= "" then
    return string.format("%s (%s)", loc, n.name)
  else
    return string.format("%s", loc)
  end
end
-----------------------------
]]

function scene:create(event)
  local sceneGroup = self.view

  trace('Must scene:create')
  -- display.setDefault('background', unpack(_G.TWITTY_COLORS.baize))

  _G.TWITTY_GROUPS.grid = self.view -- TODO referenced by Tile

  Util.setBackground(self.view)

  -- create a separate group for UI objects, so they are always on top of grid
  _G.TWITTY_GROUPS.ui = display.newGroup()
  sceneGroup:insert(_G.TWITTY_GROUPS.ui)

  _G.statusbar = Statusbar.new()
  _G.wordbar = Wordbar.new()
  _G.toolbar = Toolbar.new()
  -- scene remains in memory once created, ie it's only created once when app is run
end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  trace('Must scene:show', phase)

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)

    _G.grid:newGame()

  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen
    Runtime:addEventListener('key', scene)
    -- Runtime:addEventListener('system', scene)
--[[
    if profileThreshold > 0 then
      debug.sethook(hook, "c")  -- turn on the hook
    end
]]
  end
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  trace('Must scene:hide', phase)

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    if not Runtime:removeEventListener('key', scene) then
      trace('ERROR: could not removeEventListener key in scene:hide')
    end
    -- if not Runtime:removeEventListener('system', scene) then
    --   trace('ERROR: could not removeEventListener system in scene:hide')
    -- end
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
--[[
    if profileThreshold > 0 then
      debug.sethook()   -- turn off the hook
      for func, count in pairs(Counters) do
        if count > profileThreshold then
          print(getname(func), count)
        end
      end
    end
]]
  end
end

function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  trace('Must scene:destroy')
  _G.grid:destroy()
  composer.removeScene('Twitty')

end

function scene:key(event)
  local phase = event.phase

  if phase == 'up' then
    if event.keyName == 'back' or event.keyName == 'deleteBack' then
      Util.sound('ui')
      _G.grid:cancelCountdown()
      _G.grid:deleteTiles()
      composer.gotoScene('ModeMenu')
      return true -- override the key
    elseif event.keyName == 'h' then
      _G.grid:hint()
    elseif event.keyName == 's' then
      _G.grid:shuffle()
    elseif event.keyName == 'u' then
      _G.grid:undo()
    elseif event.keyName == 'w' then
      _G.grid:showFoundWords()
    end
  end
end

function scene:system(event)
  -- print( "System event name and type: " .. event.name, event.type )
  if event.type == 'applicationExit' then
  elseif event.type == 'applicationSuspend' then
    _G.grid:pauseCountdown()
  elseif event.type == 'applicationResume' then
    _G.grid:resumeCountdown()
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)
-- -----------------------------------------------------------------------------------

return scene
