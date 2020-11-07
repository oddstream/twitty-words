--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

_G.application =
{
  content =
  {
    --[[
      16:9 – This is the HDTV standard or 720p (1280×720) or 1080p (1920×1080).
      This is very common to many modern phones too. This works out to 1:1.777778
      if you want to measure it based on a 1 point scale.

      Moto G4 reports 1080x1776, spec says 1080x1920
      Moto G4 Plus spec says 1080x1920
      Moto G8 Power spec says 1080x2300
      Moto G8 Power Lite spec says 720x1600
    ]]
    width = 1080,
    height = 1776,

    -- width = 1080,
    -- height = 1920,

    -- width = 720,
    -- height = 1280,

    -- The scaling method of the content area is determined by the scale value.
    -- If you omit this (not recommended), the width and height values will be ignored and the content area will be set to the device's actual pixel width and height.
    -- scale = 'letterbox',
    -- scale = 'zoomEven',   -- made titlebar half disappear
    scale = 'adaptive',
    -- xAlign = 'center',
    -- yAlign = 'center',
    -- fps = 60, -- seems ok
  },
}
