# Ribbons — FAQ and spoiler guide

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

Deliberate. The page shows only what a Pokémon *has* — no locked rows, no
"3 of 18", nothing hinting at what's missing. If a Pokémon has none, the
page says so and A closes it.

The one number on screen is a scroll position, and it counts only ribbons
that Pokémon already has: `1-4/9` on a Pokémon with nine ribbons. It
never tells you how many exist in total.
</details>

<details>
<summary>A Pokémon has lots of ribbons. Do they all fit?</summary>

Four are visible at once. **Up** and **Down** scroll one row at a time,
and **A** or **B** closes the screen. When a Pokémon has more than four,
the header shows your position — `1-4/9` means you're looking at the
first four of the nine ribbons *it has*. That number is never a count of
ribbons you haven't earned.

If you also run **G1R HoldToScrollUI**, holding a direction auto-repeats
here for free — this screen polls ordinary directional input, so it picks
that up without either mod knowing about the other.
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

**If your save came from a real cartridge**, that flag isn't there — it's
something gen1recomp records, not the original game, so it can't survive
the import. Your save knows you took *a* starter but not which one. In
that case the mod works it out from ownership instead: the only way to
get a second starter-family Pokémon in Gen 1 is a trade, and traded
Pokémon carry someone else's trainer ID, so the one that's originally
yours is your starter. If somehow more than one qualifies, it awards
nothing and says so in the log rather than picking wrong.

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
<summary>Best Friends Ribbon — how do I raise happiness?</summary>

Two different ways, depending on what you have installed.

**Without the Happiness mod:** Yellow only, and it uses the game's real
Pikachu happiness value (the one the follower Pikachu's mood reflects).
Keep it in your party, keep it healthy, win battles, don't let it faint.
At maximum happiness the ribbon is awarded to your **lab** Pikachu
specifically — a traded or wild one won't take it.

**With [Happiness](https://github.com/thorkdev/gen1recomp-happiness)
installed:** every Pokémon tracks its own happiness, not just Pikachu.
Any Pokémon that reaches the cap earns the ribbon, whatever species it is
and however you got it — a traded or wild-caught Pokémon can earn this
one, unlike the Pikachu-only path. More than one Pokémon can hold the
ribbon at once. It's retroactive: a Pokémon already at max happiness gets
the ribbon the next time your save syncs, with nothing to redo.

Both paths can be active on the same save without conflicting — the
Happiness mod deliberately leaves Yellow's lab Pikachu to vanilla's own
system rather than tracking it too, so nothing double-counts.
</details>

<details>
<summary>Summit Ribbon — how do I get one?</summary>

**Gen 2 only** (Gold, Silver and Crystal). Climb Mt Silver and beat Red at the top. Every Pokémon in
your party at that moment gets the ribbon — not just the ones that
fought, the same way the Hall of Fame Ribbon works.

It is **not retroactive**, and that one is not laziness. Gen 2 records
Red with a flag that is already switched on when you start a new game
(it is the flag that keeps him hidden until you have earned the right to
meet him), so there is no honest way to look at an old save and tell
whether you beat him. Awarding it from that flag would hand the ribbon
to every brand-new save instead. So the mod has to be installed and
running when you win.
</details>

<details>
<summary>Contest ribbons — how do I win them?</summary>

Win a Contest, which needs the **Kanto Contests** mod. Appeal to the
judge with moves that match the contest's category until his appeal
meter is full — the Pokémon that performed gets the ribbon.

There are **twenty** of them: one for each of the five categories (Cool,
Beauty, Cute, Smart and Tough), at each of the four ranks (Normal,
Super, Hyper and Master). The icon's shape tells you the category and
its colour tells you the rank — bronze, silver, gold, then iridescent
for Master.

**All twenty are winnable.** Each contest hall runs one rank and you
climb by travelling, the way Generation III did it: Goldenrod runs
Normal, Ecruteak Super, Cianwood Hyper and Blackthorn Master.

The win is recorded on that Pokémon, not in a list somewhere, so the
ribbon is retroactive: if you won a Contest before installing this
version, it turns up the next time your save syncs. It also survives
boxing, evolution, trading, and removing the Contests mod afterwards.

Without the Contests mod installed, no contest ribbon is ever awarded —
there's nothing in a vanilla save that records a Contest, and this mod
would rather award nothing than guess.
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
<summary>Shiny Ribbon — Gen 1 doesn't have shinies, does it?</summary>

Not officially. But the community-standard "virtual shiny" applies the
Gen 2 shiny formula backwards to Gen 1 DVs, and a Pokémon that would be
shiny in Gen 2 can be identified in Gen 1. This mod uses the engine's
own implementation of that formula rather than its own version, so it
agrees with any other shiny-aware mod you have installed. Fully
retroactive — DVs never change, so an old save's shinies are found on
load.
</details>

<details>
<summary>Fossil Ribbon — which Pokémon count?</summary>

Omanyte, Omastar, Kabuto, Kabutops and Aerodactyl — the same list Kanto
Achievements uses for its Fossil Revival achievement, so the two agree.
It must be originally yours; a traded one won't claim it. Gen 1 doesn't
record a revival event, so strictly this checks species + original
trainer — but in an unmodified game those five have no other source, so
in practice it means exactly what it says.
</details>

<details>
<summary>Earth and Warrior — how are these different?</summary>

Same counter, two tiers: 100 wins for Earth, 250 for Warrior, both for
one individual Pokémon in the active slot. Same relationship as
Winning (10) and Victory (25), except those are for *streaks* across
your whole party, while these are one Pokémon's lifetime tally.
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
with: your Ribbons version (from the load log), your game version
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

That means the mod isn't loaded (check the load log for the Ribbons
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
