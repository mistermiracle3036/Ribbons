# Ribbons

Permanent, per-Pokémon **ribbons** for **gen1recomp** — Red, Blue, Yellow
and **Gold, Silver and Crystal** — reimagined from the Generation III–IX ribbon system for
things these games actually simulate. Ribbons live on the Pokémon itself,
so they survive boxing, evolution and trades, and they open straight from
the status screen: press A past the last page.

*(Formerly "Kanto Ribbons" — renamed with Gen 2 support, since the ribbons
are no longer a Kanto-only affair. Same mod, same saves, nothing to
reinstall.)*

> **Still growing.** New ribbons and refinements land regularly, but
> nothing here ever revokes a ribbon it has already awarded, so updating
> is always safe. Bug reports and ideas are welcome in
> [GitHub Issues](../../issues) — please include the version from your
> load log and which other mods were enabled.

Want the exact award conditions, prices and locations? Open the
**[FAQ and spoiler guide](FAQ.md)** — every detailed answer is collapsed
so you only reveal what you want.

## Icon selection in 0.24.1

New art is used for Starter, Shiny, Fossil, Best Friends, Victory,
Gorgeous, and all contest categories at every rank. Other ribbons use
their original art. The original four-row ribbons interface is restored.

## Features

- **Thirty-eight ribbons**, earned several ways: story milestones, hard
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
  the **front of your party** when you buy. Kanto games only for now.

## The ribbons

| Ribbon | How you get it | Retroactive? |
| ------ | -------------- | ------------ |
| Starter | The Pokémon you were given — Oak's lab, Elm's lab, or a starter another mod handed you | Yes |
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
| Best Friends | Max happiness — native on Gen 2; on Gen 1 it needs [Happiness](https://github.com/thorkdev/gen1recomp-happiness)§ | Yes |
| Winning | In the party for a 10-battle win streak | No |
| Victory | In the party for a 25-battle win streak | No |
| Gorgeous | Bought from the Meowth, Celadon Mansion 1F — ₽10,000† | — |
| Royal | Same Meowth — ₽100,000, needs Gorgeous first† | — |
| Gorgeous Royal | Same Meowth — ₽999,999, needs Royal first† | — |
| Summit | Beat Red at the top of Mt Silver — **Gen 2 only** | No |

**Contest ribbons** — twenty more, with **Kanto Contests** installed‡. One
per category per rank, Generation III style:

| Ribbon | How you get it | Retroactive? |
| ------ | -------------- | ------------ |
| Cool | Won a COOL contest at Normal rank‡ | Yes‡ |
| Cool Super | Won a COOL contest at Super rank‡ | Yes‡ |
| Cool Hyper | Won a COOL contest at Hyper rank‡ | Yes‡ |
| Cool Master | Won a COOL contest at Master rank‡ | Yes‡ |
| Beauty | Won a BEAUTY contest at Normal rank‡ | Yes‡ |
| Beauty Super | Won a BEAUTY contest at Super rank‡ | Yes‡ |
| Beauty Hyper | Won a BEAUTY contest at Hyper rank‡ | Yes‡ |
| Beauty Master | Won a BEAUTY contest at Master rank‡ | Yes‡ |
| Cute | Won a CUTE contest at Normal rank‡ | Yes‡ |
| Cute Super | Won a CUTE contest at Super rank‡ | Yes‡ |
| Cute Hyper | Won a CUTE contest at Hyper rank‡ | Yes‡ |
| Cute Master | Won a CUTE contest at Master rank‡ | Yes‡ |
| Smart | Won a SMART contest at Normal rank‡ | Yes‡ |
| Smart Super | Won a SMART contest at Super rank‡ | Yes‡ |
| Smart Hyper | Won a SMART contest at Hyper rank‡ | Yes‡ |
| Smart Master | Won a SMART contest at Master rank‡ | Yes‡ |
| Tough | Won a TOUGH contest at Normal rank‡ | Yes‡ |
| Tough Super | Won a TOUGH contest at Super rank‡ | Yes‡ |
| Tough Hyper | Won a TOUGH contest at Hyper rank‡ | Yes‡ |
| Tough Master | Won a TOUGH contest at Master rank‡ | Yes‡ |

\* Snag syncs retroactively for Pokémon snagged with **Pokemon Snag 0.7.4 or
newer**, which marks them permanently. Older snags are still awarded live
at the moment of capture, but can't be recovered after the fact.

† All three go to whichever Pokémon is at the **front of your party**
(slot 1) at the moment of purchase — not a Pokémon you pick from a menu.
Rearrange your party first if you want a specific one decorated. The
three are strictly sequential: you can't skip ahead to Royal without
Gorgeous already on that Pokémon.

‡ Contest ribbons need the **Kanto Contests** mod, which is what records
the win. All five categories at all four ranks are winnable — each hall
runs one rank, and you climb by travelling: **Goldenrod** Normal,
**Ecruteak** Super, **Cianwood** Hyper, **Blackthorn** Master.

The ribbon goes to the Pokémon that actually performed, and because the
record lives on the Pokémon it survives boxing, evolution, trading and
removing the Contests mod afterwards. It is retroactive for any win
recorded by **Kanto Contests 0.34.44 or newer**, which is the version
that began storing which rank a win happened at — so a Pokémon that won
before you installed this mod still gets its ribbons on the next save
load. Wins recorded before that version kept only a count, not a rank,
and earn their category's Normal ribbon alone: a Pokémon can reach
Master rank without ever winning Super, so counting wins would hand out
ribbons nobody earned. Without the Contests mod nothing is awarded —
this mod never guesses which Pokémon might have won something.

§ On **Gold, Silver and Crystal** happiness is part of the game, so every
Pokémon tracks it and no companion mod is needed. On **Red, Blue and
Yellow** it is not: without **Happiness** installed the ribbon is Yellow
only, and only your lab Pikachu, using Yellow's own native system. With
it installed, every Pokémon tracks happiness and reaching the cap earns
the ribbon whatever species it is — retroactively, and no matter how the
Pokémon came to you, since happiness travels with a Pokémon rather than
proving where it came from. More than one Pokémon can hold this ribbon.

Win streaks are counted from the moment you install the mod — a streak you
were already on doesn't count, because the save doesn't record which
Pokémon were with you for it.

## Installation

**From my mod index** (easiest, and updates come to you):

1. Mod manager → **Find Mods** → **Add index**.
2. Paste `mistermiracle3036/mod-index`.
3. Install Ribbons from the list.

**Or from a zip:**

1. Download `kanto_ribbons-<version>.zip` from the
   [latest release](../../releases/latest).
2. In the launcher: **MODS → Import mod .zip**. On iOS, delete any older
   downloaded copy of the zip from Files first.
3. Fully quit and relaunch.

Requires gen1recomp **0.1.38 or newer**. No other mod and no engine change
is required.

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
  optional, and the source of the Cool Ribbon. Reads the per-category
  `mon.contestWins` record it writes on the Pokémon that performed, so
  contest ribbons apply retroactively and survive that mod being removed.
  Needs v0.7.3 or newer; it's out now, currently an alpha with the COOL
  contest only.
- **[Happiness](https://github.com/thorkdev/gen1recomp-happiness)** —
  optional. Reads `mon.happiness`, the 0–255 value it tracks for every
  Pokémon, so the Best Friends Ribbon isn't Pikachu-only when this is
  installed. Reads the field directly; no version floor.
- **Kanto Achievements** — optional. Reserved for future ribbons that
  reuse its tracked stats rather than re-counting them.
- **gen1_modern_ui** — works. The ribbons screen opens the same way
  (A past the last summary page); Modern UI users see the mod's own
  screen styling rather than Modern UI's, since Modern UI's API doesn't
  accept external pages.
- Works in **Red, Blue, Yellow, Gold, Silver and Crystal**. A few ribbons differ by game,
  and all of it is automatic — nothing to configure:
  - **Best Friends** needs no extra mod on the Gen 2 games, where happiness is
    built in. On Red/Blue/Yellow it needs Happiness (above), and without
    that it is Yellow's lab Pikachu only.
  - **Starter** uses each game's own record of the Pokémon you were
    given, so it is exact on both and follows the whole evolution line.
  - The three **shop ribbons** are Kanto-only for now; Gen 2 has no
    Meowth selling them. A vendor in Goldenrod is planned.
  - **Snag** and **Cool** need mods that are themselves Gen 1 only.
  - The **Wide ribbons screen** option does nothing on Gen 2, which draws
    its screens a different way.

## A note on how it hooks in

The stock status screen has no mod extension point, so this mod patches
one engine function (`SummaryMenu.update`) **at runtime, in memory** —
declared via the `engine_internals` permission, the same mechanism Snag
Quest uses for its battle changes. No file on disk is modified, and
removing the mod removes the patch.

## Dev toggles

Both are on the mod's own options screen and both default to off.
Turning either back off leaves whatever was granted in place, same as
any other ribbon here — nothing in this mod revokes an award.

- **[DEV] Give lead all ribbons** — keeps party slot 1 fully decorated,
  for testing the display.
- **[DEV] Max lead happiness** — sets the lead Pokémon's happiness to
  maximum so the Best Friends Ribbon can be tested without the long
  climb. Only raises a value that already exists, so it does nothing
  unless the [Happiness](https://github.com/thorkdev/gen1recomp-happiness)
  mod is installed.

## Credits

- All icon art (`ribbons.png`) was drawn for this mod; it ships nothing
  copied from any game or any other artist.
- **Miss Default Bunny** — suggested the Shiny Ribbon, in the gen1recomp
  Discord.
- **LeHaz** — reported the missing Starter Ribbon on imported saves
  (fixed in 0.20.1).
- **WizzStar** — [G1R HoldToScrollUI](https://github.com/WizzStar/PKMN-G1R-HoldToScrollUI-Mod)
  inspired the scrolling ribbons screen (not a dependency; see
  THIRD_PARTY_NOTICES).
- **thorkdev** — [Happiness](https://github.com/thorkdev/gen1recomp-happiness)
  is the optional Gen 1 source for the Best Friends Ribbon.
- Pokémon and all related names are trademarks of Nintendo / Creatures
  Inc. / GAME FREAK inc.

Licensed under [MIT](LICENSE) — the licence covers this mod's own code
and art, not ROM-derived material or the trademarks above.
Built for [gen1recomp](https://github.com/bryanthaboi/gen1recomp).
See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
