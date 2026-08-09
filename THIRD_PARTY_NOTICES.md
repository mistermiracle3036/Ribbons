# Third-party notices

- **gen1recomp** — this mod targets the
  [gen1recomp](https://github.com/bryanthaboi/gen1recomp) engine (mod
  API 2) and reaches engine internals under the `engine_internals`
  permission: it patches `SummaryMenu.update` in memory at runtime to
  chain the ribbons screen into the status-screen page cycle. Its
  bundled tests also drive engine modules directly.
- **Pokemon Snag** — optional integration. Reads the `mon.snagged` marker
  it sets on snagged Pokémon (0.7.4+) so the Snag Ribbon can apply
  retroactively; no code is shared.
- **Kanto Achievements** — optional; reserved for future ribbons that
  read its exported stats.
- The ribbon system reimagined here is inspired by the Generation III–IX
  ribbons of the official games; no assets or data from those games are
  included. All icon art (`ribbons.png`) is original to this mod.
- **G1R HoldToScrollUI** by WizzStar
  (https://github.com/WizzStar/PKMN-G1R-HoldToScrollUI-Mod) is not a
  dependency and no code from it is used, but its interaction design
  prompted the 0.12.0 scroll redesign: the ribbons screen polls
  ordinary directional input the same way any menu does, so a player
  who also has that mod installed gets its hold-to-repeat behavior on
  this screen for free.
- The Shiny Ribbon was suggested by **Miss Default Bunny** in the
  gen1recomp Discord.
- Pokémon and all related names are trademarks of Nintendo / Creatures
  Inc. / GAME FREAK inc. This mod contains no ROM data or copyrighted
  assets; it is a fan-made script mod and requires the user's own game
  copy via gen1recomp.
