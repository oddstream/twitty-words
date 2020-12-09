-- Must.lua

-- local const = require 'constants'
local const = require 'constants'
local globalData = require 'globalData'

local Dim = require 'Dim'
local Grid = require 'Grid'

local Statusbar = require 'Statusbar'
local Wordbar = require 'Wordbar'
local Toolbar = require 'Toolbar'

local Util = require 'Util'

local composer = require('composer')
local scene = composer.newScene()
local widget = require('widget')

widget.setTheme('widget_theme_android_holo_dark')

-- local gpgs = require 'plugin.gpgs.v2'

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

  trace('Twitty scene:create')

  Util.setBackground(self.view)

  globalData.mode = event.params.mode

  globalData.dim = Dim.new(const.VARIANT[globalData.mode].width, const.VARIANT[globalData.mode].height)
  -- grid (of slots) has no graphical elements, and does not change size, so persists across all games
  globalData.grid = Grid.new(globalData.dim.numX, globalData.dim.numY)

  globalData.gridGroup = self.view

  -- create a separate group for UI objects, so they are always on top of grid
  globalData.uiGroup = display.newGroup()
  sceneGroup:insert(globalData.uiGroup)

  globalData.statusbar = Statusbar.new()
  globalData.statusbar:setLeft('☰ ' .. globalData.mode)

  globalData.wordbar = Wordbar.new()
  globalData.toolbar = Toolbar.new()
  -- scene remains in memory once created, ie it's only created once when app is run
end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  trace('Twitty scene:show', phase)

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)

    if not Runtime:addEventListener('key', scene) then
      trace('ERROR: could not addEventListener key in Twitty scene:show')
    end
    -- if not Runtime:addEventListener('system', scene) then
    --   trace('ERROR: could not addEventListener system in scene:show')
    -- end

    globalData.grid:newGame()

  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen
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

  trace('Twitty scene:hide', phase)

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    if not Runtime:removeEventListener('key', scene) then
      trace('ERROR: could not removeEventListener key in Twitty scene:hide')
    end
    -- if not Runtime:removeEventListener('system', scene) then
    --   trace('ERROR: could not removeEventListener system in scene:hide')
    -- end
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    globalData.grid:destroy()
    composer.removeScene('Twitty')
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
  trace('Twitty scene:destroy')

end

function scene:key(event)
  local phase = event.phase

  if phase == 'up' then
    if event.keyName == 'back' or event.keyName == 'deleteBack' then
      Util.sound('ui')
      globalData.grid:cancelGame()
      composer.gotoScene('ModeMenu', {effect='slideRight'})
      return true -- override the key
    elseif event.keyName == 'a' then
      Util.showAlert('GAME OVER', 'Do you want an alert?', {'Yes','No','Maybe'})
    elseif event.keyName == 'h' then
      globalData.grid:hint()
    elseif event.keyName == 'g' then
      do
        local before = collectgarbage('count')
        collectgarbage('collect')
        local after = collectgarbage('count')
        print('collected', math.floor(before - after), 'KBytes, now using', math.floor(after), 'KBytes')
      end
    elseif event.keyName == 'd' then
      -- trace('#_G.DICTIONARY_TRUE', #_G.DICTIONARY_TRUE)
      -- trace('#_G.DICTIONARY_FALSE', #_G.DICTIONARY_FALSE)
      -- trace('#_G.DICTIONARY_PREFIX_TRUE', #_G.DICTIONARY_PREFIX_TRUE)
      -- trace('#_G.DICTIONARY_PREFIX_FALSE', #_G.DICTIONARY_PREFIX_FALSE)
      trace('#_G.DICT_TRUE', #_G.DICT_TRUE)
      trace('#_G.DICT_FALSE', #_G.DICT_FALSE)
      trace('#_G.DICT_PREFIX_TRUE', #_G.DICT_PREFIX_TRUE)
      trace('#_G.DICT_PREFIX_FALSE', #_G.DICT_PREFIX_FALSE)
    elseif event.keyName == 'x' then
      local al = Util.showAlert('DEBUG', 'Check dictionaries?', {'Yes','No','Maybe'},
        function(event)
          if 1 == event.index then
            Util.checkDictionaries()
          end
        end)
        -- local al = Util.showAlert('DEBUG', 'Merge dictionaries?', {'Yes','No','Maybe'},
        --   function(event)
        --     if 1 == event.index then
        --       Util.mergeIntoHintDictionary({'AAA','BBB','ZOOM','ZZZ'})
        --     end
        --   end)
    end
  end
end

--[[
function scene:system(event)
  -- print( "System event name and type: " .. event.name, event.type )
  if event.type == 'applicationExit' then
  elseif event.type == 'applicationSuspend' then
    globalData.grid:pauseCountdown()
  elseif event.type == 'applicationResume' then
    globalData.grid:resumeCountdown()
  end
end
]]

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)
-- -----------------------------------------------------------------------------------

return scene
