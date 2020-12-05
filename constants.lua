-- constants.lua

local C = {}

C.FONTS = {
  ACME = 'assets/Acme-Regular.ttf',
  ROBOTO_MEDIUM = 'assets/Roboto-Medium.ttf',
  ROBOTO_BOLD = 'assets/Roboto-Bold.ttf',
}

-- https://en.wikipedia.org/wiki/Scrabble_letter_distributions
C.SCRABBLE_LETTERS = '  AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ'
-- assert(string.len(C.SCRABBLE_LETTERS)==100)

C.SCRABBLE_SCORES = {
  [' '] = 0,
  A = 1,
  B = 3,
  C = 3,
  D = 2,
  E = 1,
  F = 4,
  G = 2,
  H = 4,
  I = 1,
  J = 8,
  K = 5,
  L = 1,
  M = 3,
  N = 1,
  O = 1,
  P = 3,
  Q = 10,
  R = 1,
  S = 1,
  T = 1,
  U = 1,
  V = 4,
  W = 4,
  X = 8,
  Y = 4,
  Z = 10,
}

C.TOUTES_DIRECTIONS = {'n','ne','e','se','s','sw','w','nw'}

local function RGB2DEC(r,g,b)
  local n = 1/255
  return {r*n, g*n, b*n}
end

C.COLORS = {
  uiforeground = {1,1,1},
  uibackground = {0.1,0.1,0.1},
  uicontrol = RGB2DEC(255, 228, 181),  -- moccasin
  shadow = {0.1,0.1,0.1},
  -- uicontrol = {51*4/1020,181*4/1020,229*4/1020}, -- color from widget_theme_android_holo_dark@4x.png

  -- baize = {240*4/1020, 1, 240*4/1020},  -- Honeydew
  -- baize = {250*4/1020, 235*4/1020, 215*4/1020},  -- AntiqueWhite
  -- baize = {255*4/1020, 245*4/1020, 238*4/1020},  -- SeaShell
  -- baize = {248*4/1020, 248*4/1020, 255*4/1020},  -- GhostWhite

  tile = {1, 1, 0.94}, -- ivory

  baize = RGB2DEC(210, 180, 140), -- Tan
  selected = RGB2DEC(255, 215, 0),  -- Gold
  tappy = RGB2DEC(255, 228, 181), -- Moccasin
  roboto = RGB2DEC(135, 206, 250), -- LightSkyBlue

  -- baize = RGB2DEC(135, 206, 250), -- LightSkyBlue
  -- selected = RGB2DEC(30, 144, 255),  -- Dodgerblue
  -- tappy = RGB2DEC(30, 144, 255),

  -- baize = RGB2DEC(0, 128, 0), -- Green
  -- selected = RGB2DEC(102, 205, 170),  -- MediumAquamarine
  -- tappy = RGB2DEC(102, 205, 170),

  -- ivory = {1, 1, 0.94},
  -- moccasin = RGB2DEC(255, 228, 181),
  -- gold = {1, 0.84, 0},

  -- white = {1,1,1},
  -- offwhite = {0.91,0.9,0.9},
  -- aqua = {0,1,1},
  -- red = {1,0,0},
  -- orange = {1,0.65,0},
  -- pink = RGB2DEC(1,192,203),
  -- blue = {0,0,1},
  -- green = {0,1,0},
  -- purple = {0.5,0,0.5},
  gray = {0.5,0.5,0.5},
  black = {0,0,0},
}

C.SOUNDS = {
  dummy = print('constants.SOUNDS.dummy'),

  complete = audio.loadSound('assets/complete.wav'),

  failure = {
    audio.loadSound('assets/error_006.ogg'),
    audio.loadSound('assets/error_007.ogg'),
    audio.loadSound('assets/error_008.ogg'),
  },

  select = {
    audio.loadSound('assets/click1.ogg'),
    audio.loadSound('assets/click2.ogg'),
    audio.loadSound('assets/click3.ogg'),
    audio.loadSound('assets/click4.ogg'),
    audio.loadSound('assets/click5.ogg'),
  },

  shuffle = {
    audio.loadSound('assets/maximize_004.ogg'),
    audio.loadSound('assets/maximize_005.ogg'),
    audio.loadSound('assets/maximize_006.ogg'),
    audio.loadSound('assets/maximize_007.ogg'),
    audio.loadSound('assets/maximize_008.ogg'),
    audio.loadSound('assets/maximize_009.ogg'),
  },

  swap = {
    audio.loadSound('assets/minimize_001.ogg'),
    audio.loadSound('assets/minimize_002.ogg'),
    audio.loadSound('assets/minimize_003.ogg'),
    audio.loadSound('assets/minimize_004.ogg'),
    audio.loadSound('assets/minimize_005.ogg'),
    audio.loadSound('assets/minimize_006.ogg'),
    audio.loadSound('assets/minimize_007.ogg'),
    audio.loadSound('assets/minimize_008.ogg'),
    audio.loadSound('assets/minimize_009.ogg'),
  },

  found = {
    audio.loadSound('assets/confirmation_001.ogg'),
    audio.loadSound('assets/confirmation_002.ogg'),
    audio.loadSound('assets/confirmation_003.ogg'),
    audio.loadSound('assets/confirmation_004.ogg'),
  },

  shake = audio.loadSound('assets/error_008.ogg'),

  timer = audio.loadSound('assets/question_004.ogg'),

  ui = {
    audio.loadSound('assets/back_001.ogg'),
    audio.loadSound('assets/back_002.ogg'),
    audio.loadSound('assets/back_003.ogg'),
    audio.loadSound('assets/back_004.ogg'),
  },
}

C.VARIANT = {
  CASUAL = {
  },
  URGENT = {
    width = 7,
    height = 7,
    timer = 60 * 4,
  },
  TWELVE = {
    words = 12,
  },
  ROBOTO = {
  },
  PACKED = {
    width = 10,
    height = 10,
  },
}

return setmetatable({}, {
  __index = C,
  __newindex = function() error("attempted to modify read only constants table") end,
  __metatable = false })
