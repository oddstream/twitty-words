-- Must.lua

local Dim = require 'Dim'
local Grid = require 'Grid'
local Toolbar = require 'Toolbar'

local composer = require('composer')
local scene = composer.newScene()
local widget = require('widget')

widget.setTheme('widget_theme_android_holo_dark')

local function loadDictionary()
  -- look for dictionary file in resource directory (the one containing main.lua)
  local filePath = system.pathForFile('Collins Scrabble Words (2019).txt', system.ResourceDirectory)
  local file = io.open(filePath)
  if not file then
    trace('ERROR: Cannot open', filePath)
  else
    trace('opened', filePath)
    _G.DICTIONARY = file:read('*a')
    io.close(file)
    trace('dictionary length', string.len(_G.DICTIONARY))
  end
end

function scene:create(event)
  local sceneGroup = self.view

  display.setDefault('background', unpack(_G.MUST_COLORS.baize))

  _G.MUST_GROUPS.ui = display.newGroup()
  sceneGroup:insert(_G.MUST_GROUPS.ui)

  _G.MUST_GROUPS.grid = display.newGroup()
  sceneGroup:insert(_G.MUST_GROUPS.grid)

  loadDictionary()

  _G.DIMENSIONS = Dim.new()

  -- _G.titleBar = Titlebar.new({group=_G.MUST_GROUPS.ui})
  _G.toolBar = Toolbar.new({group=_G.MUST_GROUPS.ui})

  _G.grid = Grid.new(_G.DIMENSIONS.numX, _G.DIMENSIONS.numY)
  _G.grid:newGame()

end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen
    Runtime:addEventListener('key', scene)
    Runtime:addEventListener('system', scene)
  end
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    if not Runtime:removeEventListener('key', scene) then
      trace('could not removeEventListener key in scene:hide')
    end
    if not Runtime:removeEventListener('system', scene) then
      trace('could not removeEventListener system in scene:hide')
    end
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene('Must')
  end
end

function scene:destroy(event)
  local sceneGroup = self.view

  _G.grid:destroy()

  -- Code here runs prior to the removal of scene's view
end

function scene:key(event)
  local phase = event.phase

  if phase == 'up' then
    if event.keyName == 'j' then
      _G.grid:jumble()
    elseif event.keyName == 'r' then
      _G.grid:addRowAtTop()
    elseif event.keyName == 'w' then
      composer.showOverlay('FoundWords', {effect='slideRight'})
    end
  end
end

function scene:system(event)
  -- print( "System event name and type: " .. event.name, event.type )
  -- if event.type == 'applicationExit' then
  -- elseif event.type == 'applicationSuspend' then
  -- elseif event.type == 'applicationResume' then
  -- end
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
