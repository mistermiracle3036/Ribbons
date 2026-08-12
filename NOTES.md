# Development notes — parked work and verified findings

Working notes, not player docs. Facts below were verified against engine
v0.1.78 source on 2026-08-11 unless dated otherwise.

## Engine v0.1.79 re-check (2026-08-12)

Re-verified against the v0.1.79 tag rather than the release prose. Nothing
in this mod broke.

- `gen2check` on 0.21.4: **ok, will load, 1 warning** — the same MK403
  (this file requires `src.ui.SummaryMenu`, which Gold never
  instantiates). Expected and harmless: the Gen 2 sibling is patched
  alongside it, and the scanner cannot see that. `validate --strict` and
  `lint` clean.
- **The Goldenrod vendor's route still holds.** `map_scripts` is still
  gated on Gen 2 (`Schemas.gatedFor("map_scripts", 2) == true`), so the
  Gen 1 talk-script pattern remains dead there; `WorldAPI:spawnNpc`,
  `WorldAPI:queueScript` and the `world.interacted` emit carrying
  `mapId/x/y/kind` all survive, so the planned route is intact.
- **The Hatched ribbon's seam still holds.** `egg.hatched` is still
  emitted from `Breeding.lua` with the hatchling attached.
- Nothing in 0.1.79's new APIs applies here: `pokemon.sprite` on Gold
  (this mod draws no sprites), `battle.caught_marker_visible` (Gen 1
  only), `mod.datetime`, `reorderParty`. `mod.storage` is deliberately
  NOT adopted — the only persistent state here is a win-streak counter
  that should travel with the player's save, which is exactly what
  `mod.save` is for.

## ENGINE BUG: mod options do not persist on a Gold boot

Found by another mod's device report, 2026-08-12, engine v0.1.78-0.1.79.
**Not specific to this mod** — it hits every mod with options.

`ManagerState:setOption` writes `save.options.modOptions[...]`, and on
Gold `save.options` IS Gold's own nested block (stored under the `gold`
key), while `Loader:_loadState` reads the TOP-LEVEL `modOptions`. The
write and the read never meet.

Consequences for this mod's three toggles:

- A toggle flipped on a **Gold** boot lasts that session only.
- A toggle left ON from a **Red** boot is live on Gold and **cannot be
  turned off from there**.

That second case is the dangerous one here, because nothing in this mod
ever revokes a ribbon: **`[DEV] Give lead all ribbons` left on from a Red
session would decorate a Gold lead with all eighteen, permanently.** Both
dev toggles default to off, so only someone who deliberately enabled them
is exposed — but that someone is us, during testing.

Workaround: **toggle on a Red boot**, where `save.options` is the
top-level table the loader actually reads.

Not guarded in code yet, deliberately: gating the dev toggles to Gen 1
would remove a testing capability to work around an engine bug that may
be fixed next release. Re-check each engine bump; if it persists, the
guard becomes worth it.

## Gen 2 (Gold) roadmap

Standing direction: new work targets Gold first, Red gets backfill.
`games` is declared as of 0.21.0. That is a claim the mod WORKS on Gold,
so it must not be published until a real Gold boot confirms it — the test
draft is the right place for it, a public release is not.

**0.21.0 — the Gold port** (BUILT, awaiting a real Gold boot):

Done in 0.21.0:

- `games: ["gen1","gen2"]` declared. `game_version` deliberately left at
  `>=0.1.38` — nothing here needs a newer engine floor, and raising it
  would strand Gen 1 players for nothing.
- BOTH SummaryMenu classes are patched, chosen by which module exists
  rather than by asking the generation: Gold never instantiates
  `src.ui.SummaryMenu` and Gen 1 never instantiates the gen2 one, so each
  wrapper is dead code on the other side.
- Gold chain point is **A on BLUE_PAGE (3)** — Gold's own update "quits on
  the last page and otherwise falls through", so that is its equivalent of
  Gen 1's past-the-last-page beat. Deliberately NOT intercepted: the
  move-detail sub-screen (A there picks up/places a move) and EGG slots
  (`mon.isEgg`), whose arm has no pages at all.
- Gold PUSHES the ribbons screen rather than popping the summary first,
  because `close()` runs a caller-owned `onClose`. Consequence: on Gold, B
  returns to the summary; on Gen 1 it returns to the party list. A
  deliberate difference.
- The Meowth shop's `map_scripts` registration is skipped on Gen 2. The
  engine blesses registering unconditionally (Loader.lua:733-737, the
  drop is non-fatal) BUT reports it into `loader.errors`, which is the
  mod manager's `[ERRS]` screen — the one visible channel on iOS. A red
  line under a working mod reads as breakage, and nothing is lost by not
  writing a registration that would be discarded.
- Verified headlessly on both generations with `Loader.new{generation=N}`
  AND `GameVersion.set(...)` so both signals agree (they diverge if only
  the loader seam is set, which is why an earlier run looked like a
  failure): `state=loaded` both sides, **zero** kanto_ribbons `[ERRS]`
  lines both sides, Meowth shop present on red and absent on gold, both
  ribbons screens registered on both.

Still to do here:

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
