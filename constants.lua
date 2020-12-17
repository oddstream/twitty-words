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
  shadow = {0.3,0.3,0.3},
  -- uicontrol = {51*4/1020,181*4/1020,229*4/1020}, -- color from widget_theme_android_holo_dark@4x.png

  Tan = RGB2DEC(210,180,140),
  Gold = RGB2DEC(255,215,0),
  Moccasin = RGB2DEC(255,228,181),
  LightSkyBlue = RGB2DEC(135,206,250),
  Ivory = RGB2DEC(255,255,240),
  DodgerBlue = RGB2DEC(30,144,255),
  Green = RGB2DEC(0,128,0),
  MediumAquamarine = RGB2DEC(102,205,170),
  CornflowerBlue = RGB2DEC(100,149,237),
  MediumSeaGreen = RGB2DEC(60,179,113),

  -- https://en.wikipedia.org/wiki/Web_colors
  Black = {0,0,0},
  DarkSlateGray = RGB2DEC(47, 79, 79),
  DimGray = RGB2DEC(105,105,105),
  SlateGray = RGB2DEC(112,128,144),
  Gray = {0.5,0.5,0.5},
  LightSlateGray = RGB2DEC(119, 136, 153),
  DarkGray = RGB2DEC(169,169,169),
  Silver = RGB2DEC(192,192,192),
  LightGray = RGB2DEC(211,211,211),
  Gainsboro = RGB2DEC(220,220,220),

  -- https://coolors.co/c1c1c1-645e9d-4c2c69-575a4b-2a2c24
  Ebony = RGB2DEC(87, 90, 75),
  PineTree = RGB2DEC(42, 44, 36),
  SpanishViolet = RGB2DEC(76, 44, 105),
  DarkBlueGray = RGB2DEC(100, 94, 157),

  -- https://coolors.co/454851-73956f-7bae7f-95d7ae-fceff9
  RomanSilver = RGB2DEC(123, 128, 142),
  RussianGreen = RGB2DEC(115, 149, 111),
  DarkSeaGreen = RGB2DEC(123, 174, 127),
  TurquoiseGreen = RGB2DEC(149, 215, 174),
  LavenderBlush = RGB2DEC(252, 239, 249),
}

C.PALETTE = {
  GREEN = {
    baize = C.COLORS.DarkSeaGreen,
    tile = C.COLORS.LavenderBlush,
    tappy = C.COLORS.RussianGreen,
    selected = C.COLORS.TurquoiseGreen,
    roboto = C.COLORS.RomanSilver
  },
  BLUE = {
    baize = C.COLORS.CornflowerBlue,
    tile = C.COLORS.Ivory,
    tappy = C.COLORS.LightSkyBlue,
    selected = C.COLORS.Gold,
    roboto = C.COLORS.Silver
  },
  NATURAL = {
    baize = C.COLORS.Tan,
    tile = C.COLORS.Ivory,
    tappy = C.COLORS.Moccasin,
    selected = C.COLORS.Gold,
    roboto = C.COLORS.Silver
  },
  -- Gray has been the preferred American spelling since approximately 1825, although grey is an accepted variant.
  GRAY = {
    baize = C.COLORS.Ebony,
    tile = C.COLORS.Silver,
    tappy = C.COLORS.DarkBlueGray,
    selected = C.COLORS.Gold,
    roboto = C.COLORS.DarkBlueGray
  },
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

C.FILES = {
  MAIN_DICTIONARY = system.pathForFile('words_alpha_cleaned.txt', system.ResourceDirectory),
  SYS_HINT_DICTIONARY = system.pathForFile('hintdict.txt', system.ResourceDirectory),
  USR_HINT_DICTIONARY = system.pathForFile('hintdict.txt', system.DocumentsDirectory),
}

C.VARIANT = {
  SPARSE = {
    width = 5,
    height = 5,
    deductions = true,
    showPercent = true,
    description = 'Small game on a small grid - a good place to start',
  },
  URGENT = {
    width = 7,
    height = 7,
    timer = 60 * 4,
    deductions = true,
    description = 'Get your best score in four minutes',
  },
  ROBOTO = {
    width = 7,
    height = 7,
    robot = true,
    scoreTarget = 420,
    description = 'Score 420 before the robot can',
  },
  FILLUP = {
    width = 7,
    height = 7,
    showFree = true,
    description = 'Find words faster than new tiles are added',
  },
  PACKED = {
    width = 10,
    height = 10,
    deductions = true,
    showPercent = true,
    description = 'A casual game but with all one hundred tiles',
  },
  CASUAL = {
    width = 7,
    height = 7,
    deductions = true,
    showPercent = true,
    description = 'Get your best score in your own time',
  },
  -- TWELVE = {
  --   width = 7,
  --   height = 7,
  --   words = 12,
  --   description = 'Get your best score with twelve words'
  -- },
}

return setmetatable({}, {
  __index = C,
  __newindex = function() error("attempted to modify read only constants table") end,
  __metatable = false })
