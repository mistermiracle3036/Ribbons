# Development notes — parked work and verified findings

Working notes, not player docs. Facts below were verified against engine
v0.1.78 source on 2026-08-11 unless dated otherwise.

## Gen 2 (Gold) roadmap

Standing direction: new work targets Gold first, Red gets backfill.
`games` stays undeclared until the mod is tested on a real Gold boot —
declaring it asserts the mod works there.

**0.21.0 — the Gold port** (planned):

- Chain the ribbons screen into `src/ui/gen2/SummaryMenu.lua` (the
  gen2check MK403 finding — Gold never instantiates the Gen 1
  SummaryMenu, so the current patch installs cleanly and does nothing).
  Three palette-named pages, different shape from Gen 1's; read it before
  wiring. Screen id is `Gen2SummaryMenu`.
- Move the ribbon shop to a **new vendor NPC in Goldenrod** (developer
  decision, 2026-08-11). Gold has `CELADON_MANSION_1F` but
  `TEXT_CELADONMANSION1F_MEOWTH` is not in `rom_manifest_gold.json`, so
  the Gen 1 Meowth takeover has no target there — and Kanto is post-game
  in Gold anyway. Gen 1 keeps the Celadon Meowth unchanged.
- Gold NPC dialogue CANNOT use the Gen 1 spawnNpc + map_scripts pattern —
  it fails silently (`map_scripts` has no Gen 2 home). The one route:
  listen for `world.interacted` with `kind = "none"`, match the faced
  (mapId, x, y), drive text via `mod.world:queueScript`. Gen 2 `movement`
  is NUMERIC (`STANDING_DOWN = 6`), and runtime objects need a respawn
  guard on `map.entered`. This pattern is being device-proven by another
  mod first (Court of Noctowl).
- Snag Ribbon and Cool Ribbon stay Gen 1-only until snag_quest /
  kanto_contests themselves port.

**0.22.0 — Hatched ribbon** (planned, after the port):

- Awarded live on the engine's `egg.hatched` event
  (`src/core/gen2/Breeding.lua:1114`) — payload carries the hatchling mon
  after it already sits in the party slot.
- Live-only, honestly: the engine stamps no persistent "was hatched"
  marker (`caughtLevel` is stamped on EVERY mon by `Mon.new`, verified —
  it does not distinguish hatchlings), so eggs hatched before install are
  unrecoverable. Same documented stance as Winning/Victory.
- Gen 1 has no breeding, so the event never fires there; the listener is
  capability-driven and needs no gate.
- Needs a 19th catalog entry + icon cell (egg with cracks; check
  silhouette distinctness against all 18 — closest-pair floor so far is
  174/256).

## Gen 2 findings already handled in 0.20.4

- **Money**: `save.money` (Gen 1) vs `save.player.money` (Gold,
  `src/core/gen2/Save.lua:345`) — `getMoney`/`spendMoney` try the Gen 2
  home first, by capability.
- **Hall of Fame**: flat entry list (Gen 1) vs
  `{ count, teams = { { winCount, mons = {...} } } }` (Gold,
  `src/core/gen2/HallOfFame.lua`) — `hofEntries` reads both; row fields
  (species/level/nickname) are shared.
- **Starter**: Gold sets REAL cart bits `EVENT_GOT_CYNDAQUIL_FROM_ELM`
  (27) / `_TOTODILE_` (28) / `_CHIKORITA_` (29) — numeric wEventFlags
  indices, read from `save.events` bytes. Being cart bits they survive
  .sav imports, so Gen 1's imported-save hole does not exist on Gold.
  Breeding can create own-OT family duplicates; ambiguity falls back to
  the party-before-boxes-with-warning rule.
- **Happiness**: Gold's native `mon.happiness` (max 255,
  `src/core/gen2/Happiness.lua`) is field- and range-identical to
  thorkdev's Gen 1 mod, and `syncBestFriends` already reads the field by
  capability — Best Friends needs NO change and no dependency on Gold.
- **Shiny**: formulas agree exactly (Gen 1 `SHINY_ATK` set ==
  Gold's `attack % 4 == 2 or 3`), but Gold routes through a `shiny.roll`
  hook that a direct `Stats.isShiny` call bypasses — a shiny-altering
  Gold mod would not be reflected. Cosmetic gap, parked.

## Parked / open

- Wide ribbons screen (0.19.0) is shipped but still untested on a real
  wide display.
- LeHaz's confirmation that 0.20.1's imported-save fix resolves their
  Venusaur (their save is the only one exercising that path).
- `mod.card` `known` list mentions per-tile icon colour; on Gold the
  palette system differs — recheck when the port lands.
