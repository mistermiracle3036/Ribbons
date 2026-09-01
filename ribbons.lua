-- The ribbon catalog. Display data only -- the award rules live in
-- main.lua, one resolver per id, all reachable from syncAll so every
-- ribbon that can be derived from save state applies retroactively.
--
-- Width budget (measured against Font.width, not guessed): both a
-- `short` label and a `description` get 132px, because both are drawn
-- in the same x=24 column -- 16 characters at the font's 8px advance.
-- main.lua clips overruns as a backstop, but nothing here should need
-- clipping.
--
-- The order here IS the icon-sheet cell order. The sheet is ribbons.png
-- at the REPO ROOT, not assets/ -- that was a deliberate move in
-- v0.10.3 and must not be "tidied" back into a subfolder.
--
-- `color` is a GEN 2 ONLY tint, {r, g, b} in 0-255.
--
-- Gold is a CGB game "whose colour is already IN the picture"
-- (src/core/Game2.lua's own words at its render.zones seam): a screen
-- draws in real colour and nothing remaps it afterwards, so the mod can
-- simply choose. The art is greyscale in three values -- outline 16,
-- shade 96, fill 176 -- and a multiply tint turns that into a dark
-- outline, a mid tone and a bright body of one hue, which is exactly the
-- three-tone look the icons were drawn for.
--
-- These are deliberately NOT used on Gen 1, and adding them there would
-- be a mistake worth naming: Gen 1 colour comes from SGB zones this
-- screen INHERITS from the state beneath it, and PaletteFX buckets every
-- pixel into four shades BY RED CHANNEL ALONE. A tint changes the red
-- channel, so it changes which bucket a pixel lands in -- it would
-- corrupt the shading rather than colour it. A per-ribbon recolour was
-- tried on Gen 1 once before and three of six icons collided.
--
-- Hues follow the icon's subject where there is one (heart pink, globe
-- green, bone bone-coloured) and Gen III's own contest colours for the
-- contest ribbons -- COOL is red there, not blue.

return {
  {
    id = "STARTER",
    name = "Starter Ribbon",
    short = "Starter",
    description = "First partner.",
    color = { 120, 200, 120 }, -- green, the first partner
  },
  {
    id = "HALL_OF_FAME",
    name = "Hall of Fame Ribbon",
    short = "Hall of Fame",
    description = "Champion team.",
    color = { 235, 190, 70 }, -- gold crown
  },
  {
    id = "SNAG",
    name = "Snag Ribbon",
    short = "Snag",
    description = "Taken in battle.",
    color = { 170, 110, 210 }, -- Rocket purple
  },
  {
    id = "RARE",
    name = "Rare Ribbon",
    short = "Rare",
    description = "Flawless DVs.",
    color = { 95, 195, 235 }, -- bright star
  },
  {
    id = "TRAVELER",
    name = "Traveler Ribbon",
    short = "Traveler",
    description = "Came by trade.",
    color = { 235, 150, 70 }, -- trade arrows
  },
  {
    id = "EFFORT",
    name = "Effort Ribbon",
    short = "Effort",
    description = "Stat Exp maxed.",
    color = { 215, 90, 90 }, -- hard training red
  },
  {
    id = "LEGEND",
    name = "Legend Ribbon",
    short = "Legend",
    description = "A flawless run.",
    color = { 225, 200, 105 }, -- lucky horseshoe gold
  },
  {
    id = "EARTH",
    name = "Earth Ribbon",
    short = "Earth",
    description = "100 solo wins.",
    color = { 95, 180, 130 }, -- globe green
  },
  {
    id = "WARRIOR",
    name = "Warrior Ribbon",
    short = "Warrior",
    description = "250 solo wins.",
    color = { 205, 75, 75 }, -- crossed swords
  },
  {
    id = "SHINY",
    name = "Shiny Ribbon",
    short = "Shiny",
    description = "Rare shiny hues.",
    color = { 240, 225, 120 }, -- sparkle yellow
  },
  {
    id = "FOSSIL",
    name = "Fossil Ribbon",
    short = "Fossil",
    description = "Revived fossil.",
    color = { 195, 165, 120 }, -- bone
  },
  {
    id = "BEST_FRIENDS",
    name = "Best Friends Ribbon",
    short = "Best Friends",
    description = "A happy bond.",
    color = { 240, 140, 175 }, -- heart pink
  },
  {
    id = "WINNING",
    name = "Winning Ribbon",
    short = "Winning",
    description = "A 10 win streak.",
    color = { 235, 165, 80 }, -- pennant
  },
  {
    id = "VICTORY",
    name = "Victory Ribbon",
    short = "Victory",
    description = "A 25 win streak.",
    color = { 235, 190, 70 }, -- trophy gold
  },
  {
    id = "GORGEOUS",
    name = "Gorgeous Ribbon",
    short = "Gorgeous",
    description = "Costs 10000.",
    color = { 225, 120, 185 }, -- the cheapest luxury
  },
  {
    id = "ROYAL",
    name = "Royal Ribbon",
    short = "Royal",
    description = "Costs 100000.",
    color = { 150, 115, 210 }, -- royal purple
  },
  {
    id = "GORGEOUS_ROYAL",
    name = "Gorgeous Royal Ribbon",
    short = "Gorgeous Royal",
    description = "Costs 999999.",
    color = { 235, 135, 215 }, -- both at once, louder
  },
  -- Contest ribbons are one per category, matching the contest you win.
  -- Only COOL exists in Kanto Contests today; BEAUTY/CUTE/SMART/TOUGH get
  -- their own entry and their own icon cell as that mod adds them. The
  -- resolver keys off mon.contestWins[CATEGORY], which is already recorded
  -- per category, so adding one here needs no save change.
  {
    id = "COOL",
    name = "Cool Ribbon",
    short = "Cool",
    description = "A COOL contest.",
    color = { 215, 85, 85 }, -- Gen III's COOL is red
  },
  -- Gold only: Red at the top of Mt Silver. There is no save flag to read
  -- this back from -- EVENT_RED_IN_MT_SILVER is SET on a brand-new save,
  -- because on Gold a set object flag means HIDDEN -- so the award is live
  -- only, off battle.ended, and cannot be retroactive. See NOTES.md.
  {
    id = "SUMMIT",
    name = "Summit Ribbon",
    short = "Summit",
    description = "Defeated Red.",
    color = { 170, 195, 220 }, -- snow on Silver's peak
  },
}
