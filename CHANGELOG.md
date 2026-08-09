# Changelog

## 0.12.1

- Each row now shows the full "<Name> Ribbon" (e.g. "Effort Ribbon",
  "Rare Ribbon") instead of just the short label.
- Hall of Fame Ribbon, Best Friends Ribbon, Gorgeous Royal Ribbon are most likely to error but haven’t on my device, let me know if you come across anything. clipToWidth safety net covers it either way (clips to ".." rather
  than running off-screen)

## 0.12.0

- The ribbons screen scrolls now instead of paging in fixed chunks of 3.
  Up/Down move one row at a time through the full owned list (4 visible
  at once); A or B closes from anywhere. A multi-row list shows its
  position (e.g. "2-5/7") in the corner -- scoped to what's been earned,
  never a hint about what hasn't.
- No dependency taken for this. The redesign was prompted by looking at
  G1R HoldToScrollUI by WizzStar
  (github.com/WizzStar/PKMN-G1R-HoldToScrollUI-Mod), which auto-repeats
  a held D-pad direction for any menu that polls ordinary directional
  input. This screen just polls plain Up/Down like any other menu, so a
  player who also has that mod gets free hold-to-scroll; without it,
  repeated taps scroll one row each either way. Credited in
  THIRD_PARTY_NOTICES.md.
- Row pitch tightened (30px -> 27px) to fit 4 rows instead of 3 in the
  same vertical space.

## 0.11.0

- Two new ribbons (fourteen total):
  - **Legend Ribbon** -- beat the Champion with zero party faints.
    There's no direct "this was the Champion battle" signal, so this
    reuses the Hall of Fame resolver's own detection: a fresh Hall of
    Fame entry only ever appears immediately after a Champion win
    (record_hall_of_fame runs from the Champion Room script right
    after), so a per-battle faint flag (reset on battle.started, set by
    battle.fainted) is checked at the moment a new HoF entry is seen.
    Live-only: an existing save's faint history for a past Champion
    battle isn't recorded anywhere to sync from.
  - **Earth Ribbon** -- one Pokemon wins 100 battles in the active slot.
    The count lives on the Pokemon itself (mon.earthWins), credited to
    the first healthy party member on every win -- so it travels through
    boxing and reordering like every other ribbon here, and a benched or
    fainted mon never accrues credit for a win it didn't fight. Live-only
    for the same reason as Winning/Victory: Gen1 keeps no per-mon win
    tally to recompute from an existing save.
- Fixed a real bug caught while writing this: the Legend resolver's
  "have I already checked this Hall of Fame entry" state was a single
  counter shared across every save, which would silently cross-
  contaminate on a second save (or, as testing caught directly, between
  independent saves in the same run). It now lives on the save table
  itself.
- Icon sheet extended to 224x16, fourteen cells: a shield for Legend
  (a laurel wreath was tried first and looked like a broken squiggle at
  16px -- discarded before shipping) and a globe for Earth.
- The icon-mapping test now actually reads the sheet's real dimensions
  instead of a stale hardcoded stub value, and pins the two new cells.

## 0.10.3

- Moved the icon sheet from `assets/ribbons.png` to just `ribbons.png`
  at the mod's top level. The `assets/` folder was only a convention,
  never a requirement -- nothing in the engine or the packaging tool
  enforces it -- and it was causing real upload friction on iOS/GitHub
  mobile web (creating a subfolder via the web uploader is fragile).
  Now there's exactly one file to drop in, at the same level as
  `main.lua`.

## 0.10.2

- Adopted Pokemon Snag's real install/update steps and repo pattern in
  the README (mod-manager import, the iOS stale-zip caveat, "fully quit
  and relaunch" after updating, launcher auto-update via the repo's
  releases).
- Fixed the Pokemon Snag cross-link: the real repo is
  `mistermiracle3036/Pokemon-Snag` (capitalized), not the guessed
  `pokemon-snag`.
- Restored `game_version` to `>=0.1.38 <2.0.0`, matching what the
  README now states and what Pokemon Snag itself requires. This had
  been loosened to `>=0.0.0-dev` to satisfy this repo's own unstamped
  working tree during testing -- correct for that purpose, wrong to
  ship, since real players run a packaged build with a real stamped
  engine version. The test suites now patch `Version.engine` for their
  own headless run instead of the manifest carrying the workaround.

## 0.10.1

- Starter Ribbon icon is now a classic award rosette (round medallion
  with two tails) instead of the leaf. The leaf read as an unclear blob
  once the engine's four-shade palette flattened its shading, and the
  rosette is unambiguous at 16px. Checked against the two nearest
  existing shapes -- Gorgeous's gem and Royal's ring -- and it doesn't
  collide with either.

All notable changes to Kanto Ribbons are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com); the top heading always
matches the version in `manifest.json`.

## 0.10.0

- **The engine patch is gone.** The mod is now a single self-contained
  package: no `engine_summary_pages.zip`, no engine file to replace, no
  `ui.summary.pages` hook. The one route into ribbons -- press A past the
  moves page on the status screen -- now works identically in every UI,
  including stock vanilla, by patching `SummaryMenu.update` at runtime
  under the declared `engine_internals` permission (the same mechanism the
  Modern UI path already used, applied universally; Pokemon Snag's
  `BattleState.throwBall` patch is the precedent). Input flows through
  the native summary state even when gen1_modern_ui replaces the drawing,
  which is why one patch covers both.
- Consequences of one route for everyone: the Modern UI detection code is
  deleted, `gen1_modern_ui` is no longer listed as an optional dependency
  (nothing special-cases it anymore), and the nested draw-only summary
  page is gone -- the self-drawn ribbons screen with icons, descriptions
  and A-paging is what everyone sees.
- The ribbons screen paging is now covered by a live input test
  (A advances 1 -> 2 -> 3, then closes), alongside the existing
  award/shop/streak coverage.

## 0.9.0

- Six new ribbons (twelve total):
  - **Best Friends Ribbon** -- Yellow only: awarded to YOUR lab Pikachu
    (family + OT checked, so a traded or wild Pikachu can't claim it)
    when the ported happiness system (save.pikachuHappiness,
    engine/events/pikachu_happiness.asm) hits 255. Syncs retroactively;
    inert outside Yellow.
  - **Winning Ribbon / Victory Ribbon** -- 10 and 25 straight wins,
    awarded to the whole party the moment the streak lands, like Gen
    III's tower ribbons. Live-only by design: kanto_achievements'
    maxWinStreak high-water mark can't say which mons were present when
    it was set, and guessing the current party is the slot-1 bug again.
  - **Gorgeous / Royal / Gorgeous Royal Ribbons** -- bought for the LEAD
    party mon at Gen IV's real Ribbon Syndicate prices ($10,000 /
    $100,000 / $999,999), each requiring the previous. Sold by the
    Celadon Mansion 1F Meowth -- the Pay Day Pokemon moonlighting as a
    luxury clerk -- via a mod script verb (kanto_ribbons:buy_next) that
    checks, deducts and awards atomically, so a refusal never takes
    money. The mansion granny would have been the natural vendor, but
    her text constant isn't visible in the ROM-free tree; the Meowth's
    is (data/scripts/flavor/celadon_mansion_1f.lua).
- Pagination replaces "+N MORE" truncation, which stopped being
  acceptable at twelve ribbons: owned ribbons chunk into pages of 3.
  On the nested status screen each chunk registers as its own summary
  page (A walks through them exactly like stats -> moves); the
  standalone screen pages with A and closes off the last page, B closes
  anywhere. Multi-page views show n/N in the header.
- Icon sheet extended to 192x16, twelve cells: heart (Best Friends),
  pennant (Winning), trophy (Victory), gem (Gorgeous), signet ring
  (Royal), radiant gem (Gorgeous Royal), joining the six existing
  silhouettes. Same 4-shade red-channel discipline throughout.
- The quad table tolerates a sheet shorter than the catalog (draws
  text-only rather than sampling past the edge), and the cell-mapping
  test now pins cells 1 and 12.

## 0.8.0

- Ribbons are now told apart by SHAPE, not colour: leaf (Starter), crown
  (Hall of Fame), lightning bolt (Snag), star (Rare), two-way arrows
  (Traveler), dumbbell (Effort).
- This replaces 0.7.0's per-ribbon recolour, which could never have
  worked. The engine draws through PaletteFX's shader
  (src/render/PaletteFX.lua:174), which discards hue entirely and buckets
  every pixel into one of four palette shades by RED CHANNEL alone
  (`p.r > 0.83 ? c0 : p.r > 0.5 ? c1 : p.r > 0.17 ? c2 : c3`). Measured
  against the 0.7.0 sheet, three of the six collided outright: green
  (0.31) and cyan (0.31) both landed in c2 -- the Starter/Rare match
  reported from the game -- while gold, pink and orange (all 0.91) landed
  together in c0. Only three of six would ever have looked distinct.
- Silhouettes are generated from supersampled polygons, and every pixel
  uses a red value chosen to sit unambiguously inside one shade bucket:
  outline 16 (c3), fill 176 (c1), lower-band shade 96 (c2). Nothing
  depends on hue surviving the shader, because it does not.
- Traveler started as a wing and was changed to trade arrows: at 16px the
  wing silhouette was too close to Starter's leaf to tell apart, which is
  the whole point of the shape-based approach.

## 0.7.0

- Each ribbon now has its own colour. `assets/ribbon.png` is replaced by
  `assets/ribbons.png`, a 96x16 sheet of six 16x16 cells in catalog
  order: Starter green, Hall of Fame gold, Snag purple, Rare cyan,
  Traveler pink, Effort the original orange.
- The recolour is a true palette shift of the supplied art, not a
  redraw: only the three medal tones move hue, each keeping its own
  saturation and value so the shading reads the same, while the outline
  and background plate pixels are byte-identical across all six cells.
  The generator asserts that shape equality rather than trusting it.
- One image load and one quad table regardless of how many ribbons are
  added later, instead of one image per ribbon. A sheet with fewer cells
  than the catalog draws text-only for the missing ones rather than
  sampling past its edge.
- Test added pinning the catalog-to-cell mapping (Hall of Fame draws
  cell 2, Traveler cell 5). An off-by-one here would silently give every
  ribbon the wrong colour, which no other check would catch.

## 0.6.3

- Replaced the generated placeholder rosette with real ribbon art
  (16x16 RGBA, 5 colours, opaque light background with a dark border --
  a drop-in match for what the row layout expects, so no code changed).
  The medal shape reads more clearly at this size than the placeholder
  did, and it stays legible on both the white menu background and the
  grey frame tone.

## 0.6.2

- Icon now has an opaque light plate with a 1px dark border, so it stays
  visible against the white menu background instead of looking
  transparent. Checked against both white and grey backgrounds.
- Layout pulled to the left margin and descriptions moved to their own
  full-width line below the icon. The old x=36 text column left only
  ~15 characters before the right edge, which clipped every description
  mid-word ("Flawless DVs al"). The frame is 160px on every platform --
  the phone only scales it -- so this was never mobile-specific.
- Ribbon rows now draw a `short` label ("Hall of Fame") rather than the
  full title, which did not fit beside the icon; `name` is unchanged for
  anywhere with room. Descriptions shortened to fit their measured
  budget rather than relying on truncation.
- Added `clipToWidth`, which truncates by measured `Font.width` -- so a
  future ribbon with long text is structurally unable to overflow,
  rather than depending on every string being hand-checked.
- New test `tests/ribbon_draw_test.lua` captures Font.draw calls and
  asserts nothing crosses the right margin, plus that unearned ribbons
  are omitted, the empty state shows, and an icon-load failure degrades
  to text-only. This is the check that would have caught the clipping.
- Fixed description overlapping the icon (it drew 12px below the row top,
  inside the icon's 16px height); descriptions now sit clear at 18px with
  a 30px row pitch. Found by rendering a layout mockup -- the width tests
  alone could not see it.

## 0.6.1

- FIXED: no icons or descriptions appeared for Gen1 Modern UI users.
  0.6.0 added them only to the nested status-screen page, which is
  disabled when Modern UI is active -- so that path still rendered a
  plain ListMenu of bare ribbon names. Reported from a screenshot;
  should have been caught when the icon work landed.
- The standalone ribbons screen is now self-drawn instead of a
  ListMenu, and both surfaces share ONE renderer (drawRibbonBody).
  ListMenu only supports single-line text rows, so it structurally
  could not show an icon or a second line; sharing the renderer is also
  what stops the two paths drifting apart again.
- The screen shows "No ribbons yet." when a Pokemon has none, instead
  of ListMenu's generic "Nothing here."
- If the icon fails to load, rows still draw without art and the mod
  logs a warning rather than failing the screen -- now covered by a
  test that exercises the renderer with the image load forced to fail.

## 0.6.0

- Added a placeholder icon (`assets/ribbon.png`, 16x16, a generic gold
  rosette) drawn next to each ribbon on the nested status-screen page.
  Loaded lazily through `mod.assets:image` on first draw, so a headless
  load (tests, `modkit validate`) never touches `love.graphics` and
  can't fail on it -- confirmed by re-running the full suite after
  adding the asset.
- Descriptions are now hand-written directly under each ribbon's name
  on that page, as requested, rather than only living unused in
  `ribbons.lua`. Fitting them forced a real change: the original
  descriptions were full sentences (badly, "Inducted into the Hall of
  Fame with its trainer." at ~50 characters) written before there was
  a screen to put them on. Shortened to taglines that fit one line
  next to a 16px icon with no wrapping.
- The page has no scroll or selection input of its own -- the
  `ui.summary.pages` hook only carries a draw function, not update, and
  giving pages real input is a bigger engine change than this needed --
  so instead of a Gen3-style "description of whichever ribbon is
  highlighted," all owned ribbons are hand-drawn in a fixed list. That
  caps display at 3 ribbons before the box runs out; a 4th+ shows as
  "+N MORE" rather than silently vanishing. Not reachable with the
  current six ribbons, but noted for whenever it is.
- Icon and layout are placeholders, not final art -- swap
  `assets/ribbon.png` for real per-ribbon icons whenever those exist;
  everything else (position math, the lazy-load guard) stays as is.

## 0.5.2

- Removed every "out of 6" / total count. The status-screen page, the
  standalone detail screen's title, and the party list's count column
  now show only what a Pokemon has, never what it's missing -- no
  "n/6", no implied checklist.

## 0.5.1

- Under Gen1 Modern UI, ribbons no longer appear as a party-submenu row
  (the dropdown option). Modern UI draws the summary screen itself, but
  input still flows through the native SummaryMenu state underneath --
  so the mod now patches SummaryMenu.update (engine_internals; same
  precedent as Pokemon Snag's BattleState.throwBall patch) to hand A/B on
  the last page off to the ribbons screen instead of closing. The flow
  reads STATS -> MOVES -> RIBBONS in both UIs, with no menu entry
  anywhere.
- Ribbon pages now list only OBTAINED ribbons, like the real Gen3/4
  pages: no more GOT/---- checklist. A mon with no ribbons gets an
  empty page (the standalone screen renders its usual empty-state
  line), and the header keeps the n/6 count.

## 0.5.0

- Five new ribbons alongside Starter, every one with a sync resolver so
  existing saves catch up automatically at load:
  - **Hall of Fame Ribbon** -- matched back from the save's own
    induction records (`record_hall_of_fame` appends
    { species, level, nickname } per party mon,
    src/script/Commands.lua:753) by species + nickname + your OT +
    current level >= recorded level. A foreign-OT lookalike is rejected.
  - **Snag Ribbon** -- syncs from the persistent `mon.snagged` marker
    Pokemon Snag >= 0.7.4 sets at catch time, and also awards live off
    `pokemon.caught` with `ball == "SNAG_BALL"`, which covers older
    Pokemon Snag versions (marker-less snags just can't sync
    retroactively). `snag_quest` added as an optional dependency.
  - **Rare Ribbon** -- all four rolled DVs at 15 (the HP DV is derived
    from their low bits, so 15s across the board imply HP 15 too).
    Renamed from the earlier "Rare Mark" proposal: everything here is a
    ribbon.
  - **Traveler Ribbon** -- foreign OT, the Starter resolver's own check
    inverted; covers link trades and NPC trades (which stamp
    ot = "TRAINER") retroactively, plus a live award on
    `trade.completed`.
  - **Effort Ribbon** -- all five Stat Exp values at the 65535 cap
    (src/battle/Experience.lua:60). Synced after every battle, so it
    lands near-live.
- One `syncAll` pass now runs on load, save creation, script end (lab
  grant, NPC trades, Hall of Fame induction), battle end, and
  evolution -- the live awards and the retroactive ones are the same
  resolvers throughout.
- The status-screen page now lists all six ribbons on single 12px rows.

## 0.4.0

- Gen1 Modern UI compatibility. Modern UI replaces the status screen
  wholesale (`runtime.drawSummary`) and identifies extra pages purely by
  index -- `state.page == 3` is hard-coded to DV Tracker's
  "DVs / STAT EXP" page. Our ribbons page is also page 3, so with Modern
  UI installed it rendered as a DV page: wrong content, wrong heading,
  and silently so.
- Modern UI's published adapter API
  (`docs/CUSTOM_UI_AND_THEME_API.md`) is data-first and explicitly
  rejects third-party draw callbacks, so there is no supported way to
  hand it a ribbons page for the native summary screen. Rather than
  fight it, the mod now stands down: when Modern UI is active the nested
  page is skipped and ribbons open from a RIBBONS row under STATS in the
  party submenu, which Modern UI renders through its normal list
  handling.
- Detection is lazy (`mod.find` at first hook call, not at load), so it
  works regardless of which mod the loader runs first, and logs which
  route it picked.
- `gen1_modern_ui` added as an *optional* dependency. Without it the
  nested status-screen page is unchanged.
- Verified against the real Gen1 Modern UI 0.8.2, not a stand-in.

## 0.3.0

- Ribbons now live INSIDE the status screen, as a third page after the
  stats and moves pages -- the same place Gen3 nests them. A/B walks
  onto it and off the end, exactly like the vanilla two-page cycle.
- Removed the party-submenu RIBBONS row and its standalone screen; the
  page replaces both, so no menu anywhere gains an entry.
- This needed a new engine hook, `ui.summary.pages`
  (`src/ui/SummaryMenu.lua`), since that file previously had no mod seam
  at all. Guarded by `Runtime.wantsHook`, so with no subscriber the
  screen allocates nothing and stays byte-for-byte the vanilla
  two-pager. Mod pages draw under `pcall` -- a throwing page logs and
  leaves the screen up rather than taking it down.
- Parity gate added at `tests/drivers/summary_pages_parity_test.lua`
  (no-mod behaviour + the seam driven through the public mod API).

## 0.2.0

- FIXED the wrong-Pokemon bug, properly this time. Retroactive detection
  now reads the save's `EVENT_CHOSE_BULBASAUR` / `_CHARMANDER` /
  `_SQUIRTLE` / `_PIKACHU` flag -- confirmed set by the lab script's own
  `starterBall` helper (`data/scripts/oaks_lab.lua:193-201`) and by
  `oaks_lab_yellow.lua:202` -- so the mod knows exactly which species
  your starter was, on any save, forever. No guessing, no player
  intervention.
- Matching is by evolution family, so an already-evolved starter
  (Venusaur, Charizard, Blastoise, Raichu) is still found.
- Traded Pokemon of the same species are excluded on original trainer
  (`mon.otId` / `mon.ot`, stamped by `stampOT`,
  `src/battle/BattleState.lua:510`). A traded Charizard no longer
  shadows the Charmander you actually picked.
- Boxed starters are found: the search covers the party first, then
  every box.
- Removed the 0.1.1 manual A-to-toggle control. It existed only to work
  around detection that couldn't identify the starter; detection can,
  so the workaround is gone and both screens are read-only again.
- The live (in-lab) award and the retroactive one now run the *same*
  resolver, called from `script.ended` rather than reimplemented. One
  rule instead of two that could drift apart.
- Also syncs on `save.created` and `pokemon.evolved`, so a newly added
  ribbon catches up without waiting for a reload.
- Renamed from `ribbons` to `kanto_ribbons`, matching
  `kanto_achievements` and freeing the generic id.

## 0.1.1

- Attempted fix for the ribbon landing on the wrong Pokemon: removed the
  party-slot-1 backfill entirely and added a manual toggle instead.
  Correct in that it stopped mistagging, wrong in approach -- it pushed
  work onto the player that the save data could have answered. Superseded
  by 0.2.0.
- Moved the ribbons entry from a standalone START-menu screen to the
  party submenu, directly under STATS, via `ui.party.submenu` -- the
  closest supported seam to the Pokemon's own page, since
  `src/ui/SummaryMenu.lua` exposes no hook at all.

## 0.1.0

- Initial slice: Starter Ribbon, awarded live when the lab hands over
  the ball, stored as `mon.ribbons.STARTER` on the Pokemon table.
- Known bug (fixed in 0.2.0): on a save that already had a starter, the
  ribbon was awarded to party slot 1 on the assumption the starter was
  still there. Wrong on essentially any save played past Pallet Town.
