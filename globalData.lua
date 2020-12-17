-- globalData.lua

local json = require 'json'

local const = require 'constants'

local GD = {
  paletteName = 'NATURAL',

  colorBaize = const.COLORS.Tan,
  colorTile = const.COLORS.Ivory,
  colorTappy = const.COLORS.Moccasin,
  colorSelected = const.COLORS.Gold,
  colorRoboto = const.COLORS.Silver,
}

-- GD.statusbar
-- GD.wordbar
-- GD.grid
-- GD.toolbar

-- GD.mode
-- GD.dim

-- GD.groupGrid  -- child of Twitty sceneGroup
-- GD.groupUI  -- child of Twitty sceneGroup

function GD:setPalette(paletteName)
  self.paletteName = paletteName

  local paletteValues = const.PALETTE[paletteName]
  if not paletteValues then
    paletteValues = const.PALETTE.NATURAL
  end

  self.colorBaize = paletteValues.baize
  self.colorTile = paletteValues.tile
  self.colorTappy = paletteValues.tappy
  self.colorSelected = paletteValues.selected
  self.colorRoboto = paletteValues.roboto
end

local filePath = system.pathForFile('settings.json', system.DocumentsDirectory)

function GD:loadSettings()
  local file, msg = io.open(filePath, 'r')
  if file then
    local contents = file:read('*a')
    io.close(file)
    trace('settings loaded from', filePath)
    local settings = json.decode(contents)

    if settings.paletteName then
      self:setPalette(settings.paletteName)
    end
  else
    trace('cannot open', filePath, msg)
  end
end

function GD:saveSettings()
  local settings = {paletteName = self.paletteName}
  local file, msg = io.open(filePath, 'w')
  if file then
    file:write(json.encode(settings, {indent=true}))
    trace('settings written to', filePath)
    io.close(file)
  else
    trace('cannot open', filePath, msg)
  end
end

return GD
