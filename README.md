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

- **Eighteen ribbons**, earned several ways: story milestones, hard
  training, flawless battles, lucky DVs, a Contest win, and one very
  expensive shop.
- **Awarded automatically.** Nothing to toggle or claim. If a Pokémon
  qualifies, it already has the ribbon by the time you look.
- **Retroactive on existing saves.** Most ribbons are recomputed from
  your save when you load it, so a run you started before installing this
  mod catches up on its own. Where a save genuinely records nothing to
  work from, the mod says so in the log instead of guessing.
- **Opens from the status screen** in every UI: STATS → MOVES → RIBBONS,
  all on the A button, no menu entries anywhere. Only ribbons a Pokémon
  *has* are listed — no "you're missing these" checklist. Four at a time,
  Up/Down scrolls one row, A or B closes.
- **One self-contained package.** No engine files to replace, no
  companion downloads.
- **A shop.** The Meowth in Celadon Mansion, 1F, sells three ribbons at
  escalating, deliberately absurd prices — for whichever Pokémon is at
  the **front of your party** when you buy.

## The ribbons

| Ribbon | How you get it | Retroactive? |
| ------ | -------------- | ------------ |
| Starter | The Pokémon you chose in Oak's lab | Yes |
| Hall of Fame | Was in the party that entered the Hall of Fame | Yes |
| Snag | Taken from a trainer with a Snag Ball | Yes* |
| Rare | Flawless DVs in every stat | Yes |
| Traveler | Arrived from another trainer in a trade | Yes |
| Effort | Every Stat Exp value maxed out | Yes |
| Legend | Beat the Champion with zero party faints | No |
| Earth | One Pokémon wins 100 battles in the active slot | No |
| Warrior | One Pokémon wins 250 battles in the active slot | No |
| Shiny | Born with the rare "virtual shiny" DV spread | Yes |
| Fossil | A fossil Pokémon revived by you | Yes |
| Best Friends | Yellow only — your lab Pikachu at maximum happiness | Yes |
| Winning | In the party for a 10-battle win streak | No |
| Victory | In the party for a 25-battle win streak | No |
| Gorgeous | Bought from the Meowth, Celadon Mansion 1F — ₽10,000† | — |
| Royal | Same Meowth — ₽100,000, needs Gorgeous first† | — |
| Gorgeous Royal | Same Meowth — ₽999,999, needs Royal first† | — |
| Cool | Won the COOL Contest at the Celadon Contest Hall‡ | Yes‡ |

\* Snag syncs retroactively for Pokémon snagged with **Pokemon Snag 0.7.4 or
newer**, which marks them permanently. Older snags are still awarded live
at the moment of capture, but can't be recovered after the fact.

† All three go to whichever Pokémon is at the **front of your party**
(slot 1) at the moment of purchase — not a Pokémon you pick from a menu.
Rearrange your party first if you want a specific one decorated. The
three are strictly sequential: you can't skip ahead to Royal without
Gorgeous already on that Pokémon.

‡ Contest ribbons need the **Kanto Contests** mod (v0.7.3 or newer),
which is what records the win. It goes to the Pokémon that actually
performed, and because that record is stored on the Pokémon itself, it is
retroactive: a Pokémon that won a Contest before you installed this
version still gets the ribbon the next time your save syncs, and keeps it
if you later remove the Contests mod. Without that mod nothing is awarded
— this mod never guesses which Pokémon might have won something.

Win streaks are counted from the moment you install the mod — a streak you
were already on doesn't count, because the save doesn't record which
Pokémon were with you for it.

## Installation

1. Download `kanto_ribbons-<version>.zip` from the
   [latest release](../../releases/latest).
2. In the launcher: **MODS → Import mod .zip**. On iOS, delete any older
   downloaded copy of the zip from Files first.
3. Fully quit and relaunch.
4. Requires gen1recomp **0.1.38 or newer**. No other mod and no engine
   change is required.

**Updating:** once installed, the launcher checks this repo for new
releases. The mod's entry shows "vX.Y.Z available" → tap → **Update** →
fully quit and relaunch. No manual re-download.

After installing an update, **fully quit and relaunch** the game. The
load log prints the running version so you can confirm what's live.

## Compatibility

- **[Pokemon Snag](https://github.com/mistermiracle3036/Pokemon-Snag)** —
  optional. Reads the permanent `mon.snagged` marker it sets on snagged
  Pokémon (0.7.4+) so the Snag Ribbon applies retroactively; older
  versions still award it live.
- **[Kanto Contests](https://github.com/mistermiracle3036/Kanto-Contests)** —
  optional. Reads the per-category `mon.contestWins` record it writes on
  the Pokémon that performed, so the contest ribbons apply retroactively
  and survive that mod being removed. Needs v0.7.3 or newer.
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

## Dev toggle

The mod's own options screen has **[DEV] Give lead all ribbons**
(off by default). Turn it on to keep party slot 1 fully decorated for
testing the display -- turning it back off leaves whatever was granted
in place, same as any other ribbon here.

## Credits

- **Miss Default Bunny** — suggested the Shiny Ribbon, in the gen1recomp
  Discord.
- **WizzStar** — [G1R HoldToScrollUI](https://github.com/WizzStar/PKMN-G1R-HoldToScrollUI-Mod)
  inspired the scrolling ribbons screen (not a dependency; see
  THIRD_PARTY_NOTICES).

Built for [gen1recomp](https://github.com/bryanthaboi/gen1recomp).
See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
