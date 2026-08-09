# Kanto Ribbons — FAQ and spoiler guide

Every answer is collapsed. Tap only what you want revealed.

## Basics

<details>
<summary>Where do I see a Pokémon's ribbons?</summary>

Open a Pokémon's **STATS** screen and keep pressing A: stats, then moves,
then **ribbons**. Works the same in every UI, including gen1_modern_ui.
</details>

<details>
<summary>Do I have to do anything to claim a ribbon?</summary>

No. There's nothing to toggle, buy (except the three shop ribbons) or
confirm. If a Pokémon qualifies, it already has the ribbon.
</details>

<details>
<summary>Why don't I see a list of ribbons I haven't earned?</summary>

Deliberate. The page shows only what a Pokémon *has* — no totals, no
"3/12", no locked rows. If a Pokémon has none, the page says so and A
closes it.
</details>

<details>
<summary>A Pokémon has lots of ribbons. Do they all fit?</summary>

Three per page. A turns the page; off the last page, A closes the
screen. B closes from anywhere. The header shows which page you're on.
</details>

## Ribbons that apply to old saves

<details>
<summary>Will my existing run get ribbons?</summary>

Mostly yes. When you load a save, the mod recomputes every ribbon it can
prove from what the save already stores, and awards them on the spot.
Starter, Hall of Fame, Rare, Traveler, Effort and Best Friends all work
this way, however long ago you earned them.
</details>

<details>
<summary>How does it know which Pokémon was my starter? (technical)</summary>

The game permanently records *which* starter you chose as an event flag
the moment you take the ball in Oak's lab. The mod reads that flag, then
looks for a Pokémon in that evolution family whose original trainer is
you. So an evolved starter still matches, and a **traded** Pokémon of the
same species can't be mistaken for it.

An earlier version guessed "party slot 1" instead and got this wrong on
any save where you'd caught or reordered anything. That's fixed.
</details>

<details>
<summary>My Yellow save has two Pikachu and the ribbon went to the wrong
one.</summary>

This is the one case the mod genuinely can't resolve. If you caught a
wild Pikachu, both it and your lab Pikachu are yours and in the same
family, and Gen 1 stores nothing that distinguishes them. The mod picks
party-before-boxes for a stable result and writes a warning to the log
rather than pretending it's sure. Please do report which one it picked —
it helps.
</details>

<details>
<summary>Which ribbons will NOT apply retroactively, and why?</summary>

- **Winning / Victory** (win streaks): the save records nothing about
  which Pokémon were in your party during a past streak. Counting starts
  when you install the mod.
- **Snag**, for Pokémon snagged before **Pokemon Snag 0.7.4**: older
  versions didn't mark snagged Pokémon permanently, and after the battle
  a snagged Pokémon is indistinguishable from a normally caught one.
  0.7.4+ marks them, so those do sync.

In both cases the mod could have guessed. It doesn't — a wrong permanent
award is worse than a missing one, since nothing here ever revokes a
ribbon.
</details>

## Specific ribbons

<details>
<summary>Rare Ribbon — what counts as "flawless"?</summary>

All four rolled DVs at 15. The HP DV in Gen 1 is derived from the other
four, so 15s across the board means a perfect Pokémon outright. It's
rare — don't read its absence as a bug.
</details>

<details>
<summary>Effort Ribbon — what exactly do I need?</summary>

All five Stat Exp values at the 65,535 cap. This is the Gen 1 ancestor of
EV training, and it takes a *lot* of battling.
</details>

<details>
<summary>Best Friends Ribbon — how do I raise Pikachu's happiness?</summary>

Yellow only, and it uses the game's real Pikachu happiness value (the one
the follower Pikachu's mood reflects). Keep it in your party, keep it
healthy, win battles, don't let it faint. At maximum happiness the ribbon
is awarded to your **lab** Pikachu specifically — a traded or wild one
won't take it.
</details>

<details>
<summary>Hall of Fame Ribbon — how does it find the right Pokémon?</summary>

The game writes a real Hall of Fame record: species, level and nickname
for each party member at induction. The mod matches that back against
your living Pokémon, also requiring you to be the original trainer and
the current level to be at least the recorded one. A traded lookalike
with the same nickname is rejected.
</details>

<details>
<summary>Legend Ribbon — what counts as "zero faints"?</summary>

Not one of your Pokémon can drop to 0 HP at any point during the
Champion battle — a genuinely clean sweep, start to finish. It's
awarded to the whole party the same moment Hall of Fame is, and it's
live-only: there's no way to check an old save's history for whether a
past Champion clear was clean.
</details>

<details>
<summary>Earth Ribbon — which Pokémon gets credit for a win?</summary>

Whichever Pokémon is at the front of your party AND still standing
(not fainted) when the battle ends. A benched Pokémon, or one that
fainted earlier in the fight, doesn't accrue a win that battle — the
next healthy one in line does. It's tracked on that specific Pokémon,
so trading it away or releasing it loses the count.
</details>

<details>
<summary>Winning and Victory — does the whole party get them?</summary>

Yes, every Pokémon in your party when the streak lands, matching how
Generation III's Battle Tower ribbons were awarded to the whole team.
Losing a battle resets the streak; running or catching leaves it alone.
</details>

## The shop (spoilers)

<details>
<summary>Where is the ribbon shop?</summary>

**Celadon Mansion, 1F.** Talk to the Meowth. Yes, the Meowth.
</details>

<details>
<summary>What does it sell and what does it cost?</summary>

Three ribbons, in order, each requiring the previous one:

- **Gorgeous Ribbon** — ₽10,000
- **Royal Ribbon** — ₽100,000
- **Gorgeous Royal Ribbon** — ₽999,999

These are Generation IV's real Ribbon Syndicate prices. They go to the
Pokémon at the **front of your party**, so put the one you want decorated
in slot 1 first.
</details>

<details>
<summary>I can't afford it — did it take my money anyway?</summary>

No. The purchase checks your money, deducts it and awards the ribbon as a
single step, so a refusal can't take anything. If you ever see money
disappear without a ribbon, that's a bug worth reporting.
</details>

## Troubleshooting

<details>
<summary>I talked to an NPC and they just turned to face me — nothing
happened.</summary>

That's the signature of a swallowed script error. Please open an issue
with: your Kanto Ribbons version (from the load log), your game version
(Red/Blue/Yellow), which NPC, and which other mods were enabled. If you
can, retry with other mods disabled — knowing whether that changes it
helps enormously.
</details>

<details>
<summary>I updated the mod but it's acting like the old version.</summary>

Fully quit and relaunch the game. Hot-reload can keep stale code in
memory. The load log prints the version — confirm it matches the release
you installed.
</details>

<details>
<summary>Pressing A on the moves page closes the screen instead of
showing ribbons.</summary>

That means the mod isn't loaded (check the load log for the Kanto Ribbons
version line) or another mod is replacing the status screen's *input*
handling wholesale. Please open an issue with your mod list.
</details>

<details>
<summary>The ribbon icons look wrong or indistinguishable.</summary>

The icons are told apart by **shape**, not colour, on purpose: the engine
renders through a palette that reduces everything to four shades and
discards hue, so differently coloured versions of the same shape would
come out identical. If two shapes are genuinely hard to tell apart on
your setup, that's useful feedback — please open an issue saying which.
</details>
