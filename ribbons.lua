-- The ribbon catalog. Display data only -- the award rules live in
-- main.lua, one resolver per id, all reachable from syncAll so every
-- ribbon that can be derived from save state applies retroactively.
--
-- Width budget (measured against Font.width, not guessed): a `short`
-- label has ~132px beside the icon and a `description` has ~152px on
-- its own line. main.lua clips overruns as a backstop, but nothing
-- here should need clipping.
--
-- The order here IS the icon-sheet cell order (assets/ribbons.png).

return {
  {
    id = "STARTER",
    name = "Starter Ribbon",
    short = "Starter",
    description = "Chosen in the lab.",
  },
  {
    id = "HALL_OF_FAME",
    name = "Hall of Fame Ribbon",
    short = "Hall of Fame",
    description = "Champion team.",
  },
  {
    id = "SNAG",
    name = "Snag Ribbon",
    short = "Snag",
    description = "Snagged in battle.",
  },
  {
    id = "RARE",
    name = "Rare Ribbon",
    short = "Rare",
    description = "Flawless DVs.",
  },
  {
    id = "TRAVELER",
    name = "Traveler Ribbon",
    short = "Traveler",
    description = "Came from a trade.",
  },
  {
    id = "EFFORT",
    name = "Effort Ribbon",
    short = "Effort",
    description = "Stat Exp maxed.",
  },
  {
    id = "LEGEND",
    name = "Legend Ribbon",
    short = "Legend",
    description = "Champion, no faints.",
  },
  {
    id = "EARTH",
    name = "Earth Ribbon",
    short = "Earth",
    description = "100 wins, one mon.",
  },
  {
    id = "BEST_FRIENDS",
    name = "Best Friends Ribbon",
    short = "Best Friends",
    description = "A truly happy bond.",
  },
  {
    id = "WINNING",
    name = "Winning Ribbon",
    short = "Winning",
    description = "A 10 win streak.",
  },
  {
    id = "VICTORY",
    name = "Victory Ribbon",
    short = "Victory",
    description = "A 25 win streak.",
  },
  {
    id = "GORGEOUS",
    name = "Gorgeous Ribbon",
    short = "Gorgeous",
    description = "Bought for 10000.",
  },
  {
    id = "ROYAL",
    name = "Royal Ribbon",
    short = "Royal",
    description = "Bought for 100000.",
  },
  {
    id = "GORGEOUS_ROYAL",
    name = "Gorgeous Royal Ribbon",
    short = "Gorg. Royal",
    description = "Bought for 999999.",
  },
}
