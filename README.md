# Kanto Ribbons

Permanent, per-Pokémon **ribbons** for **gen1recomp** (Red / Blue / Yellow) —
reimagined from the Generation III–IX ribbon system for things Gen 1
actually simulates. Ribbons live on the Pokémon itself, so they survive
boxing, evolution and trades, and they open straight from the status
screen: press A past the moves page.

> **Development Preview:** Kanto Ribbons is in active development. Bug
> reports and ideas are welcome in [GitHub Issues](../../issues) — please
> include the version number from your load log and which other mods were
> enabled.

Want the exact award conditions, prices and locations? Open the
**[FAQ and spoiler guide](FAQ.md)** — every detailed answer is collapsed
so you only reveal what you want.

## Features

- **Twelve ribbons**, earned three ways: story milestones, hard training,
  and one very expensive shop.
- **Awarded automatically.** Nothing to toggle or claim. If a Pokémon
  qualifies, it already has the ribbon by the time you look.
- **Retroactive on existing saves.** Most ribbons are recomputed from
  your save when you load it, so a run you started before installing this
  mod catches up on its own. Where a save genuinely records nothing to
  work from, the mod says so in the log instead of guessing.
- **Opens from the status screen** in every UI: STATS → MOVES → RIBBONS,
  all on the A button, no menu entries anywhere. Only ribbons a Pokémon
  *has* are listed — no "you're missing these" checklist — and long
  collections page with A, three to a page.
- **One self-contained package.** No engine files to replace, no
  companion downloads.
- **A shop.** The Celadon Mansion has a very stylish resident selling
  three absurdly priced ribbons.

## The ribbons

| Ribbon | How you get it | Retroactive? |
| ------ | -------------- | ------------ |
| Starter | The Pokémon you chose in Oak's lab | Yes |
| Hall of Fame | Was in the party that entered the Hall of Fame | Yes |
| Snag | Taken from a trainer with a Snag Ball | Yes* |
| Rare | Flawless DVs in every stat | Yes |
| Traveler | Arrived from another trainer in a trade | Yes |
| Effort | Every Stat Exp value maxed out | Yes |
| Best Friends | Yellow only — your lab Pikachu at maximum happiness | Yes |
| Winning | In the party for a 10-battle win streak | No |
| Victory | In the party for a 25-battle win streak | No |
| Gorgeous | Bought for ₽10,000 | — |
| Royal | Bought for ₽100,000 (needs Gorgeous) | — |
| Gorgeous Royal | Bought for ₽999,999 (needs Royal) | — |

\* Snag syncs retroactively for Pokémon snagged with **Pokemon Snag 0.7.4 or
newer**, which marks them permanently. Older snags are still awarded live
at the moment of capture, but can't be recovered after the fact.

Win streaks are counted from the moment you install the mod — a streak you
were already on doesn't count, because the save doesn't record which
Pokémon were with you for it.

## Installation

<!-- TODO/CONFIRM: exact install wording for gen1recomp (folder path vs
     mod manager import). Fill in the same steps you follow yourself. -->

1. Download `kanto_ribbons.zip` from the
   [latest release](../../releases/latest).
2. Install it like any other gen1recomp mod.
3. Requires **mod API 2**. No other mod or engine change is required.

## Compatibility

- **[Pokemon Snag](https://github.com/mistermiracle3036/pokemon-snag)** —
  optional. Reads the permanent `mon.snagged` marker it sets on snagged
  Pokémon (0.7.4+) so the Snag Ribbon applies retroactively; older
  versions still award it live.
  <!-- TODO/CONFIRM: exact repo slug -- guessed pokemon-snag from the
       "Pokemon Snag" name; fix if the URL differs -->
- **Kanto Achievements** — optional. Reserved for future ribbons that
  reuse its tracked stats rather than re-counting them.
- **gen1_modern_ui** — works. The ribbons screen opens the same way
  (A past the last summary page); Modern UI users see the mod's own
  screen styling rather than Modern UI's, since Modern UI's API doesn't
  accept external pages.
- Works in **Red, Blue and Yellow**. The Best Friends Ribbon is
  Yellow-only by design (it uses Yellow's Pikachu happiness system);
  everything else is version-agnostic.

## A note on how it hooks in

The stock status screen has no mod extension point, so this mod patches
one engine function (`SummaryMenu.update`) **at runtime, in memory** —
declared via the `engine_internals` permission, the same mechanism Snag
Quest uses for its battle changes. No file on disk is modified, and
removing the mod removes the patch.

## Credits

Built for [gen1recomp](https://github.com/bryanthaboi/gen1recomp).
See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
