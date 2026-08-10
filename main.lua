-- Kanto Ribbons: per-Pokemon ribbons reimagined for Gen1 mechanics.
--
-- Ribbons are stored on the Pokemon table itself (mon.ribbons.ID = true).
-- Mons serialize straight into the save, so this needs no save-schema
-- work and the ribbon travels with the mon through boxes and trades.
--
-- Every ribbon is awarded automatically. Two paths, and a ribbon should
-- support both wherever the data allows:
--
--   LIVE    -- tagged the moment its triggering engine event fires.
--   SYNC    -- recomputed from save state on load, so a save that
--              predates this mod (or predates a newly added ribbon)
--              catches up on its own with no player intervention.
--
-- The sync path is the important one and the reason this mod does not
-- ask the player to tag anything by hand. If a ribbon can't be synced
-- from save state, say so in ribbons_design.md rather than shipping a
-- guess -- a wrong automatic award is worse than a late one, because
-- nothing here revokes a ribbon it didn't just grant.

-- Which starter the player chose is permanently recorded in the save as
-- an event flag, set by the lab script the same moment the ball is taken
-- (data/scripts/oaks_lab.lua's starterBall, oaks_lab_yellow.lua:202).
-- That flag is what makes retroactive detection exact rather than a
-- guess: it survives evolution, boxing, party reordering and nicknaming.
--
-- Evolutions are listed so an already-evolved starter is still found on
-- an existing save.
local STARTER_FLAGS = {
  EVENT_CHOSE_BULBASAUR  = { "BULBASAUR", "IVYSAUR", "VENUSAUR" },
  EVENT_CHOSE_CHARMANDER = { "CHARMANDER", "CHARMELEON", "CHARIZARD" },
  EVENT_CHOSE_SQUIRTLE   = { "SQUIRTLE", "WARTORTLE", "BLASTOISE" },
  EVENT_CHOSE_PIKACHU    = { "PIKACHU", "RAICHU" }, -- Yellow's lab Pikachu
}

return function(mod)
  -- Same schema/pattern as Pokemon Snag's dev_replay_meowth_quest:
  -- a toggle row is { key, type = "toggle", label, default }
  -- (src/mods/ManagerState.lua's buildOptionRows), mod.options:get(key)
  -- always reads the live value, default false so it ships inert for
  -- every real player. Checked fresh in syncAll below, so flipping it
  -- mid-session takes effect on the very next sync -- no restart.
  mod.options:define({
    -- Off by default, and deliberately a choice rather than something
    -- detected. Renderer:setUISize accepts ANY width from 160 to 640
    -- without consulting the physical display (Renderer.lua:196-201), so
    -- asking for the wide canvas on a narrow phone does not fail -- it
    -- succeeds and scales the same screen down, making every glyph
    -- physically smaller. Wider is only better when the display is
    -- actually wide, and the mod cannot know that better than the player
    -- looking at it.
    { key = "wide_screen", type = "toggle",
      label = "Wide ribbons screen", default = false },
    { key = "dev_give_lead_all_ribbons", type = "toggle",
      label = "[DEV] Give lead all ribbons", default = false },
  })

  -- ------- catalog

  local source = mod:read("ribbons.lua")
  local catalog
  if source then
    local chunk, compileErr = load(source, "@" .. mod.path .. "/ribbons.lua")
    if chunk then
      local ok, result = pcall(chunk)
      if ok then catalog = result
      else mod.log:error("ribbons.lua failed to run: %s", tostring(result)) end
    else
      mod.log:error("ribbons.lua did not compile: %s", tostring(compileErr))
    end
  else
    mod.log:error("ribbons.lua missing from %s -- reinstall the mod", mod.path)
  end
  catalog = catalog or {}

  local function ribbonName(id)
    for _, r in ipairs(catalog) do
      if r.id == id then return r.name end
    end
    return id
  end

  -- ------- award primitives

  local function hasRibbon(mon, id)
    return mon ~= nil and mon.ribbons ~= nil and mon.ribbons[id] == true
  end

  local function inCatalog(id)
    for _, r in ipairs(catalog) do
      if r.id == id then return true end
    end
    return false
  end

  local function awardRibbon(mon, id, why)
    if not mon or hasRibbon(mon, id) then return false end
    mon.ribbons = mon.ribbons or {}
    mon.ribbons[id] = true
    mod.log:info("awarded %s to %s (%s)", ribbonName(id),
      mon.nickname or mon.species or "?", why or "earned")
    return true
  end

  -- every mon in the save, party first: the party is both the likelier
  -- home for a starter and the tiebreak we want if a save somehow has
  -- two equally valid candidates
  local function eachMon(save)
    local out = {}
    for _, mon in ipairs(save.party or {}) do out[#out + 1] = mon end
    for _, box in ipairs(save.boxes or {}) do
      for _, mon in ipairs(box) do out[#out + 1] = mon end
    end
    return out
  end

  -- ------- STARTER: sync
  --
  -- A starter is: the right species family for the save's EVENT_CHOSE_*
  -- flag, AND originally the player's own. The OT check (stampOT,
  -- src/battle/BattleState.lua:510) is what keeps a *traded* Charizard
  -- from being mistaken for the Charmander you picked in the lab --
  -- a traded mon carries the other trainer's name and id.

  local function starterFamily(save)
    local flags = save and save.flags
    if not flags then return nil end
    for flag, family in pairs(STARTER_FLAGS) do
      if flags[flag] then return family, flag end
    end
    return nil
  end

  local function isOwnOT(mon, save)
    local player = save.player
    if not player then return true end -- pre-OT save: don't exclude anything
    if mon.otId ~= nil and player.id ~= nil then return mon.otId == player.id end
    if mon.ot ~= nil and player.name ~= nil then return mon.ot == player.name end
    return true
  end

  -- ------- STARTER: the imported-save fallback
  --
  -- Reported by LeHaz in the gen1recomp Discord: a Red save whose starter
  -- had long since become a VENUSAUR got no Starter Ribbon at all.
  --
  -- The cause is that EVENT_CHOSE_BULBASAUR / _CHARMANDER / _SQUIRTLE /
  -- _PIKACHU are gen1recomp's OWN flags, set by its lab script
  -- (data/scripts/oaks_lab.lua's starterBall, oaks_lab_yellow.lua:202).
  -- They are not real Gen 1 wEventFlags bits, so they have no bit to
  -- decode out of an imported .sav: src/save_convert/data/event_flags.lua
  -- (and the Yellow table) contain ZERO EVENT_CHOSE_* entries, and
  -- GenSave decodes "only bits with a known name"
  -- (save_convert/GenSave.lua:733-737). EVENT_GOT_STARTER (bit 34) IS a
  -- real bit and does survive.
  --
  -- So a save played start-to-finish inside gen1recomp is fine, and a
  -- save imported from a real cartridge arrives knowing that a starter
  -- was taken but not WHICH -- and starterFamily returned nil, so the
  -- resolver bailed silently. That is precisely the "save that predates
  -- the mod" case the whole retroactive design exists to serve.
  --
  -- Recovering it without guessing: in Gen 1 the only way to obtain a
  -- second starter-family Pokemon is a trade, and a traded mon carries
  -- the other trainer's OT. So an own-OT Pokemon in a starter family is
  -- the starter -- as long as there is exactly ONE. Two or more is
  -- genuinely ambiguous (a link trade from a friend playing the same
  -- game keeps their OT, but a self-trade between your own two carts
  -- would not), and this mod does not resolve ambiguity by guessing:
  -- nothing here revokes an award, so a wrong one is permanent.
  local function starterFromOwnership(save)
    if not (save.flags and save.flags.EVENT_GOT_STARTER) then return nil end
    local anyFamily = {}
    for _, family in pairs(STARTER_FLAGS) do
      for _, species in ipairs(family) do anyFamily[species] = true end
    end
    local candidates = {}
    for _, mon in ipairs(eachMon(save)) do
      if anyFamily[mon.species] and isOwnOT(mon, save) then
        candidates[#candidates + 1] = mon
      end
    end
    if #candidates == 1 then return candidates[1] end
    if #candidates > 1 then
      mod.log:warn("EVENT_GOT_STARTER is set with no EVENT_CHOSE_* flag " ..
        "(imported save?) and %d of your Pokemon are in a starter family " ..
        "-- cannot tell which was the starter, so no ribbon was placed",
        #candidates)
    end
    return nil
  end

  local function syncStarter(save)
    if not save then return end
    local family, flag = starterFamily(save)
    if not family then
      -- no EVENT_CHOSE_* to work from; try ownership instead
      local mon = starterFromOwnership(save)
      if mon then
        awardRibbon(mon, "STARTER",
          "sole own-OT starter-family Pokemon (imported save, no " ..
          "EVENT_CHOSE_* flag)")
      end
      return
    end

    local inFamily = {}
    for _, species in ipairs(family) do inFamily[species] = true end

    local candidates = {}
    for _, mon in ipairs(eachMon(save)) do
      if inFamily[mon.species] and isOwnOT(mon, save) then
        if hasRibbon(mon, "STARTER") then return end -- already correct
        candidates[#candidates + 1] = mon
      end
    end

    if #candidates == 0 then
      -- released, traded away, or a Yellow save whose Pikachu was boxed
      -- into a lost save slot: nothing to tag, and inventing a target
      -- would be exactly the wrong-mon bug this path exists to avoid
      mod.log:info("%s is set but no untagged %s-family Pokemon of yours " ..
        "is in this save -- Starter Ribbon not placed", flag, family[1])
      return
    end

    if #candidates > 1 then
      -- e.g. a Yellow save with the lab Pikachu and a Viridian Forest
      -- Pikachu, both legitimately yours. Party-first ordering makes the
      -- pick stable rather than arbitrary; say so instead of implying
      -- certainty we don't have.
      mod.log:warn("%d of your Pokemon match the %s family -- awarding the " ..
        "Starter Ribbon to the first (party before boxes)", #candidates,
        family[1])
    end

    awardRibbon(candidates[1], "STARTER", "sync from " .. flag)
  end

  -- ------- STARTER: live
  --
  -- give_pokemon (src/script/Commands.lua) emits pokemon.before_give
  -- BEFORE the Pokemon object exists and BEFORE the lab script sets the
  -- flag, so there is nothing to award at that moment. The script.ended
  -- syncAll pass below runs after give_pokemon has placed the mon and
  -- set_flag has run -- so the sync resolver, the one already proven
  -- against every other save, is also the live award. One rule, not two
  -- that can disagree.

  -- ------- SNAG: sync + live
  --
  -- Snag Quest >= 0.7.4 sets mon.snagged = true at catch time, a
  -- persistent marker that rides into the party/box with the mon --
  -- that's the sync source. The live event covers older Snag Quest
  -- versions too: pokemon.caught carries ball = self.lastBall
  -- (src/battle/BattleState.lua:4470), so ball == "SNAG_BALL" at catch
  -- time is enough even without the marker.

  local function syncSnag(save)
    for _, mon in ipairs(eachMon(save)) do
      if mon.snagged then awardRibbon(mon, "SNAG", "sync from mon.snagged") end
    end
  end

  mod.events:on("pokemon.caught", function(ev)
    if ev and ev.ball == "SNAG_BALL" and ev.mon then
      awardRibbon(ev.mon, "SNAG", "caught with a Snag Ball")
    end
  end)

  -- ------- RARE: sync only (DVs never change, so sync is complete)
  --
  -- All four rolled DVs at 15. The HP DV is derived from their low bits
  -- (Stats.randomDVs, src/pokemon/Stats.lua:19), so 15/15/15/15 implies
  -- HP 15 too -- checking the four is checking all five.

  local function syncRare(save)
    for _, mon in ipairs(eachMon(save)) do
      local d = mon.dvs
      if type(d) == "table" and d.attack == 15 and d.defense == 15
          and d.speed == 15 and d.special == 15 then
        awardRibbon(mon, "RARE", "flawless DVs")
      end
    end
  end

  -- ------- TRAVELER: sync + live
  --
  -- Sync: OT differs from the player -- the same isOwnOT check the
  -- Starter resolver uses, inverted. Covers link trades (the received
  -- mon keeps the partner's OT) and NPC trades (Commands.trade stamps
  -- ot = "TRAINER" with a random id) alike, retroactively.
  -- Live: trade.completed (src/link/Protocol.lua:400) for link trades;
  -- NPC trades are picked up by the script.ended sync pass below.

  local function syncTraveler(save)
    for _, mon in ipairs(eachMon(save)) do
      if not isOwnOT(mon, save) then
        awardRibbon(mon, "TRAVELER", "sync from foreign OT")
      end
    end
  end

  mod.events:on("trade.completed", function(ev)
    if ev and ev.received then
      awardRibbon(ev.received, "TRAVELER", "received in a trade")
    end
  end)

  -- ------- EFFORT: sync (statExp only ever grows, capped at 65535 by
  -- src/battle/Experience.lua:60, so once true it stays true)

  local EFFORT_MAX = 65535
  local function syncEffort(save)
    for _, mon in ipairs(eachMon(save)) do
      local se = mon.statExp
      if type(se) == "table"
          and (se.hp or 0) >= EFFORT_MAX
          and (se.attack or 0) >= EFFORT_MAX
          and (se.defense or 0) >= EFFORT_MAX
          and (se.speed or 0) >= EFFORT_MAX
          and (se.special or 0) >= EFFORT_MAX then
        awardRibbon(mon, "EFFORT", "all Stat Exp maxed")
      end
    end
  end

  -- ------- HALL_OF_FAME: sync
  --
  -- record_hall_of_fame (src/script/Commands.lua:753) appends one entry
  -- per induction to save.hallOfFame, each a list of
  -- { species, level, nickname } for the party at that moment. That
  -- record is the evidence; matching it back to living mons is:
  -- same species, same nickname (nil matches nil), your OT, and current
  -- level >= the recorded level (levels never go down). Party first,
  -- and each record row claims at most one mon per pass.
  --
  -- The induction itself runs inside a script, so the script.ended sync
  -- pass below doubles as the live award -- no separate path to drift.

  local function syncHallOfFame(save)
    local hof = save.hallOfFame
    if type(hof) ~= "table" or #hof == 0 then return end
    local mons = eachMon(save)
    for _, entry in ipairs(hof) do
      for _, rec in ipairs(entry) do
        for _, mon in ipairs(mons) do
          if mon.species == rec.species
              and mon.nickname == rec.nickname
              and (mon.level or 0) >= (rec.level or 0)
              and isOwnOT(mon, save)
              and not hasRibbon(mon, "HALL_OF_FAME") then
            awardRibbon(mon, "HALL_OF_FAME",
              "sync from Hall of Fame record")
            break
          end
        end
      end
    end
  end

  -- ------- LEGEND: live only
  --
  -- "Beat the Champion with zero party faints." There is no separate
  -- signal for "this was the Champion battle" -- but a fresh Hall of
  -- Fame entry only ever appears immediately after one
  -- (record_hall_of_fame, data/scripts/story.lua:1175, runs from the
  -- Champion Room script right after the win). So: track whether ANY
  -- player-side mon faints during a battle (battle.started resets the
  -- flag, battle.fainted with battler.isPlayer sets it), and when
  -- syncHallOfFame notices a HoF entry it hasn't seen before, check
  -- whether the battle immediately preceding it was clean. Reuses the
  -- proven HoF detection rather than separately guessing which battle
  -- was the Champion fight.
  --
  -- Live only, deliberately: an existing save's history of faints
  -- during a past Champion battle isn't recorded anywhere, so this
  -- can't sync retroactively without guessing -- and a wrongly-awarded
  -- "flawless" ribbon is a worse failure than a missing one.

  local battleHadPlayerFaint = false

  mod.events:on("battle.started", function() battleHadPlayerFaint = false end)
  mod.events:on("battle.fainted", function(ev)
    if ev and ev.battler and ev.battler.isPlayer then
      battleHadPlayerFaint = true
    end
  end)

  local function syncLegend(save)
    local hof = save.hallOfFame
    if type(hof) ~= "table" then return end
    -- "how many HoF entries this save has already been checked against"
    -- lives on the save itself, not a module-level counter -- a shared
    -- counter would leak state between separate saves (or, as caught in
    -- testing, between independent save tables in the same run)
    local seen = save._krSeenHofCount or 0
    if #hof <= seen then return end -- no new induction
    local justInducted = hof[#hof]
    save._krSeenHofCount = #hof
    if battleHadPlayerFaint then
      mod.log:info("Champion clear had at least one faint -- no Legend Ribbon")
      return
    end
    local mons = eachMon(save)
    for _, rec in ipairs(justInducted) do
      for _, mon in ipairs(mons) do
        if mon.species == rec.species and mon.nickname == rec.nickname
            and isOwnOT(mon, save) then
          awardRibbon(mon, "LEGEND", "flawless Champion clear")
          break
        end
      end
    end
  end

  -- ------- SHINY: sync only (DVs never change, so sync is complete)
  --
  -- Gen 1 has no shiny flag; the community-standard "virtual shiny" is
  -- the Gen 2 formula read back against Gen 1 DVs. The engine already
  -- implements exactly that in Stats.isShiny (src/pokemon/Stats.lua:90),
  -- so this calls it rather than re-deriving the DV rules here -- if the
  -- engine's definition ever changes, this follows it instead of
  -- silently disagreeing.

  local Stats = require("src.pokemon.Stats")

  local function syncShiny(save)
    for _, mon in ipairs(eachMon(save)) do
      if Stats.isShiny(mon.dvs) then
        awardRibbon(mon, "SHINY", "shiny DV spread")
      end
    end
  end

  -- ------- FOSSIL: sync only
  --
  -- A revived fossil Pokemon. The species list matches the one
  -- kanto_achievements uses for its own "Fossil Revival" achievement, so
  -- the two agree about what counts. When that mod is installed this
  -- reads ITS list at runtime (achievement id "fossil_revival",
  -- condition.species) rather than keeping a second copy that could
  -- drift; the local list below is the standalone fallback.
  --
  -- OT-checked like every other origin ribbon, so a traded Kabutops
  -- doesn't claim a revival you didn't perform. Note this can't tell a
  -- revived fossil from one caught by other means (Gen1 records no
  -- revival event), but in an unmodified game these five species have
  -- no other legitimate source, so species + your OT is exact in
  -- practice.
  local FOSSIL_SPECIES_FALLBACK = {
    "OMANYTE", "OMASTAR", "KABUTO", "KABUTOPS", "AERODACTYL",
  }

  local fossilSpeciesSet -- resolved once, on first use
  local function fossilSpecies()
    if fossilSpeciesSet then return fossilSpeciesSet end
    local list = FOSSIL_SPECIES_FALLBACK
    local ka = mod.find("kanto_achievements")
    local ok, theirs = pcall(function()
      for _, a in ipairs(ka.exports.achievements) do
        if a.id == "fossil_revival" and a.condition
            and type(a.condition.species) == "table" then
          return a.condition.species
        end
      end
    end)
    if ok and type(theirs) == "table" and #theirs > 0 then
      list = theirs
      mod.log:info("using kanto_achievements' fossil species list (%d entries)",
        #theirs)
    end
    fossilSpeciesSet = {}
    for _, sp in ipairs(list) do fossilSpeciesSet[sp] = true end
    return fossilSpeciesSet
  end

  local function syncFossil(save)
    local species = fossilSpecies()
    for _, mon in ipairs(eachMon(save)) do
      if species[mon.species] and isOwnOT(mon, save) then
        awardRibbon(mon, "FOSSIL", "revived fossil species")
      end
    end
  end

  -- ------- EARTH / WARRIOR: live only, per-mon "in the active slot"
  -- win counter, two tiers.
  --
  -- "One mon wins N battles in the active slot." kanto_achievements'
  -- win counters are per-save, not per-mon, so this needs its own
  -- tracking regardless. The active slot at the moment of victory is
  -- approximated as the first living, non-fainted party mon at
  -- battle.ended -- exactly the mon that was active when the last enemy
  -- went down for a normal win.
  --
  -- The count lives on the mon itself (mon.earthWins), not in mod.save,
  -- so it survives boxing/reordering and isn't confused between mons.
  -- Live only: Gen1 doesn't record a per-mon win tally to sync from.
  --
  -- Two tiers, mirroring the Winning(10)/Victory(25) streak pair:
  -- Earth at 100, Warrior at 250.
  local WIN_TIERS = {
    { at = 100, id = "EARTH" },
    { at = 250, id = "WARRIOR" },
  }

  local function creditEarthWin(save)
    if not save then return end
    for _, mon in ipairs(save.party or {}) do
      if (mon.hp or 0) > 0 then
        mon.earthWins = (mon.earthWins or 0) + 1
        for _, tier in ipairs(WIN_TIERS) do
          if mon.earthWins >= tier.at and not hasRibbon(mon, tier.id) then
            awardRibbon(mon, tier.id,
              ("%d wins in the active slot"):format(tier.at))
          end
        end
        return -- credit only the first (front-most) healthy mon
      end
    end
  end

  -- ------- BEST_FRIENDS: sync
  --
  -- TWO independent sources, because two different systems can own a
  -- Pokemon's happiness and they do not overlap.
  --
  -- 1. VANILLA YELLOW. Yellow's Pikachu happiness is a real ported system
  --    (src/world/PikachuFollower.lua, engine/events/pikachu_happiness.asm):
  --    save.pikachuHappiness, 0..255, starting at 90. Max bond = the Best
  --    Friends Ribbon, awarded to the lab Pikachu itself -- the same
  --    family + OT match the Starter resolver uses, so a wild-caught or
  --    traded Pikachu can't claim it. Non-Yellow saves never set
  --    EVENT_CHOSE_PIKACHU, so this arm is inert everywhere else.
  --
  -- 2. THE HAPPINESS MOD (thorkdev/gen1recomp-happiness, id "happiness"),
  --    which gives EVERY Pokemon a 0..255 `mon.happiness`. Read straight
  --    off the mon, so this is retroactive and survives that mod being
  --    uninstalled, exactly like mon.contestWins. That mod publishes no
  --    exports at all, so the field IS the whole contract -- there is
  --    nothing to call and nothing to version-check.
  --
  -- The arms must stay separate rather than one replacing the other: for
  -- a PIKACHU on a Yellow save the happiness mod deliberately never
  -- writes mon.happiness and leaves save.pikachuHappiness to vanilla
  -- (its own `isYellowPikachu` carve-out), so arm 2 cannot see the
  -- companion Pikachu and arm 1 is still the only thing that can award
  -- it. Reading mon.happiness for that mon would find nothing.
  --
  -- No OT check on arm 2, deliberately, and unlike arm 1. Arm 1 asks
  -- "is this the Pikachu you were given in the lab" -- an identity
  -- question, where a traded lookalike would be wrong. Arm 2 asks "did
  -- this Pokemon reach maximum happiness", which is true however it came
  -- to you: happiness travels with the mon, and if you walked a traded
  -- Pokemon to 255 that bond is yours.
  --
  -- One ribbon per Pokemon, not one per save: several mons can max out,
  -- and each has earned it.

  local MAX_HAPPINESS = 255 -- both systems use the same 0..255 range

  local function syncBestFriends(save)
    -- arm 1: vanilla Yellow companion Pikachu
    if save.flags and save.flags.EVENT_CHOSE_PIKACHU
        and (save.pikachuHappiness or 0) >= MAX_HAPPINESS then
      for _, mon in ipairs(eachMon(save)) do
        if (mon.species == "PIKACHU" or mon.species == "RAICHU")
            and isOwnOT(mon, save) then
          awardRibbon(mon, "BEST_FRIENDS", "Pikachu happiness maxed")
          break -- one lab Pikachu, one bond
        end
      end
    end

    -- arm 2: any mon the happiness mod has taken to the cap
    for _, mon in ipairs(eachMon(save)) do
      if type(mon.happiness) == "number" and mon.happiness >= MAX_HAPPINESS then
        awardRibbon(mon, "BEST_FRIENDS", "happiness maxed")
      end
    end
  end

  -- ------- GORGEOUS / ROYAL / GORGEOUS_ROYAL: bought, Gen IV Ribbon
  -- Syndicate style: escalating prices, each requiring the previous,
  -- applied to the LEAD party mon. Sold by the Celadon Mansion Meowth
  -- (the Pay Day Pokemon moonlighting as a luxury clerk) -- one of the
  -- three constants confirmed present in
  -- data/scripts/flavor/celadon_mansion_1f.lua. The granny's constant
  -- isn't visible in the ROM-free tree, so the Meowth it is.

  local SHOP_TIERS = {
    { id = "GORGEOUS", price = 10000 },
    { id = "ROYAL", price = 100000 },
    { id = "GORGEOUS_ROYAL", price = 999999 },
  }

  -- one command checks+deducts+awards atomically; the script branches on
  -- ctx.lastCheck and the KR_SHOP_LINE token reads the message it left
  mod.content.commands:register("kanto_ribbons:buy_next", {
    foreground = true,
    fn = function(ctx)
      local save = ctx.save
      local lead = save.party and save.party[1]
      ctx.lastCheck = false
      local function say(line) ctx.game.krShopLine = line end
      if not lead then
        say("No POKeMON?\nBring your lead\nout front, meow.")
        return
      end
      local tier
      for _, t in ipairs(SHOP_TIERS) do
        if not hasRibbon(lead, t.id) then tier = t break end
      end
      if not tier then
        say("That one wears\nall three already.\nMagnificent, meow!")
        return
      end
      if (save.money or 0) < tier.price then
        say(("%s?\nThat's $%d.\nMeow-t of range?"):format(
          ribbonName(tier.id), tier.price))
        return
      end
      save.money = save.money - tier.price
      awardRibbon(lead, tier.id, ("bought for $%d"):format(tier.price))
      say(("Sold! %s\nfor %s.\nMeow-velous!"):format(
        ribbonName(tier.id), lead.nickname or lead.species or "your friend"))
      ctx.lastCheck = true
    end,
  })

  mod.content.tokens:register("KR_SHOP_LINE", function(game)
    return game.krShopLine or "Meow?"
  end)

  mod.content.map_scripts:register("CELADON_MANSION_1F", {
    priority = 500,
    talk = {
      TEXT_CELADONMANSION1F_MEOWTH = {
        { "face_player" },
        { "show_text", "Meowth: Meow!\nRibbons for the\ndiscerning owner!\f"
          .. "$10000, $100000,\n$999999. Each needs\nthe one before.\f"
          .. "For the POKeMON at\nthe front of your\nparty. Interested?" },
        { "choice", { "BUY", "NO THANKS" } },
        { "jump_if_false", "bye" },
        { "kanto_ribbons:buy_next" },
        { "show_text", "{KR_SHOP_LINE}" },
        { "jump", "end" },
        { "label", "bye" },
        { "show_text", "Meow. The finer\nthings wait for\nno one." },
      },
    },
  })

  -- ------- sync entry points
  -- game.ready: { game = <Game> } -- fires with save already attached.
  -- save.loaded: { save = <table>, meta, modsDiff } -- no `game` field.

  -- While the toggle above is on, the lead (party[1]) is kept fully
  -- decorated on every sync -- for screen/layout testing, not intended
  -- to leave on. Turning it back off does NOT strip ribbons it granted:
  -- nothing in this mod ever revokes an award, same as every other
  -- ribbon here, so a debug decoration behaves exactly like a real one
  -- once given. Idempotent either way (awardRibbon no-ops on a ribbon
  -- the mon already has), so this is safe to run every sync.
  local function devAwardAllToLead(save)
    if mod.options:get("dev_give_lead_all_ribbons") ~= true then return end
    local lead = save.party and save.party[1]
    if not lead then return end
    for _, r in ipairs(catalog) do
      awardRibbon(lead, r.id, "[DEV] award-all toggle")
    end
  end

  -- ------- CONTEST: sync
  --
  -- Kanto Contests (mistermiracle3036/Kanto-Contests) records a win on
  -- the mon that actually performed, as mon.contestWins[CATEGORY] = n.
  -- That is the same on-the-mon shape as mon.earthWins, so it survives
  -- boxing, evolution and trading exactly like the ribbon it earns.
  --
  -- It also makes this resolver retroactive in the way this mod prefers:
  -- the win is in the save, not in a live event, so a Pokemon that won a
  -- contest before this ribbon existed picks it up on the next sync.
  -- Nothing here guesses -- a save with no contestWins awards nothing.
  --
  -- Deliberately NOT gated on kanto_contests being loaded. The data is
  -- in the save either way, so a player who uninstalls the contest mod
  -- keeps a ribbon already earned; nothing in this mod revokes.
  --
  -- No OT check: a contest win belongs to the Pokemon that performed,
  -- and ribbons travel with it, so a traded winner keeps it. (Starter
  -- and Fossil check OT because those ask "did YOU get this here" --
  -- a different question.)
  --
  -- One ribbon per contest CATEGORY, matching the contest you won, the way
  -- Gen III did it. Only COOL is reachable today because Kanto Contests
  -- only runs a COOL contest -- the rest are listed here so that adding
  -- one is a catalog entry plus an icon cell and nothing else. A category
  -- with no catalog entry simply awards nothing.
  --
  -- 0.16.0 shipped this for one turn as a single "CONTEST" ribbon. A save
  -- from that build carries a stale mon.ribbons.CONTEST, which is inert:
  -- the screen renders from the catalog, so an id no longer in it is not
  -- drawn. Nothing is lost, because the win itself lives in
  -- mon.contestWins and re-resolves to the COOL ribbon on the next sync.
  local CONTEST_RIBBONS = {
    COOL = "COOL", BEAUTY = "BEAUTY", CUTE = "CUTE",
    SMART = "SMART", TOUGH = "TOUGH",
  }

  local function syncContest(save)
    if not save then return end
    for _, mon in ipairs(eachMon(save)) do
      local wins = mon.contestWins
      if type(wins) == "table" then
        for category, count in pairs(wins) do
          local id = CONTEST_RIBBONS[category]
          -- only award an id the catalog actually defines: a category
          -- whose ribbon has not been drawn yet must write nothing to the
          -- save rather than a flag for a ribbon that cannot be shown
          if id and inCatalog(id) and type(count) == "number" and count > 0 then
            awardRibbon(mon, id, ("won a %s contest"):format(category))
          end
        end
      end
    end
  end

  local function syncAll(save)
    if not save then return end
    syncStarter(save)
    syncSnag(save)
    syncRare(save)
    syncTraveler(save)
    syncEffort(save)
    syncShiny(save)
    syncFossil(save)
    syncHallOfFame(save)
    syncLegend(save)
    syncBestFriends(save)
    syncContest(save)
    devAwardAllToLead(save)
  end

  local activeGame

  -- ------- WINNING (10) / VICTORY (25): live streak, whole party
  --
  -- Gen III's tower ribbons went to the whole selected team, so these go
  -- to every party mon the moment the streak lands. The streak is this
  -- mod's own mod.save counter -- kanto_achievements tracks maxWinStreak
  -- too, but its high-water mark can't say WHICH mons were in the party
  -- when it was set, and guessing the current party is the slot-1 bug
  -- again. So: live-only; a streak from before this mod was installed
  -- earns nothing, honestly.

  local STREAK_RIBBONS = { { at = 10, id = "WINNING" }, { at = 25, id = "VICTORY" } }

  local function onBattleEnded(result, save)
    if not save then return end
    if result == "win" then
      creditEarthWin(save)
      local streak = mod.save:get("win_streak", 0) + 1
      mod.save:set("win_streak", streak)
      for _, t in ipairs(STREAK_RIBBONS) do
        if streak == t.at then
          for _, mon in ipairs(save.party or {}) do
            awardRibbon(mon, t.id, ("win streak of %d"):format(streak))
          end
        end
      end
    elseif result == "lose" then
      mod.save:set("win_streak", 0)
    end
    -- run/caught leave the streak alone, like a tower set neither broken
    -- nor extended by a non-battle exit
  end

  mod.events:on("game.ready", function(ev)
    activeGame = ev and ev.game or activeGame
    syncAll(activeGame and activeGame.save)
  end)
  mod.events:on("save.loaded", function(ev) syncAll(ev and ev.save) end)
  mod.events:on("save.created", function(ev) syncAll(ev and ev.save) end)

  -- scripts cover the lab grant, NPC trades, and the Hall of Fame
  -- induction; one pass at script end catches all three live
  mod.events:on("script.ended", function(ev)
    local ctx = ev and ev.ctx
    if ctx and ctx.save then syncAll(ctx.save) end
  end)

  -- battles are where statExp grows, snags happen, and streaks build; one
  -- pass on battle.ended keeps all of those near-live
  mod.events:on("battle.ended", function(ev)
    local save = activeGame and activeGame.save
    onBattleEnded(ev and ev.result, save)
    syncAll(save)
  end)

  -- an evolving starter stays the same table, so its ribbon follows it
  -- for free; this only covers a mon that became eligible by evolving
  mod.events:on("pokemon.evolved", function(ev)
    syncAll((ev and ev.game and ev.game.save)
      or (activeGame and activeGame.save))
  end)

  -- kept in lockstep with manifest.json's version (release checklist
  -- item 1); other mods and the load log read this
  mod.exports.version = "0.20.2"
  mod.exports.hasRibbon = hasRibbon
  mod.exports.catalog = catalog

  -- ------- screens

  local function ribbonCount(mon)
    local have = 0
    for _, r in ipairs(catalog) do
      if hasRibbon(mon, r.id) then have = have + 1 end
    end
    return have
  end

  local function monLabel(mon)
    local def = mod.content.pokemon:get(mon.species)
    return mon.nickname or (def and def.name) or mon.species
  end

  -- KantoRibbonsDetail is registered below, after drawRibbonPage exists.

  mod.content.screens:register("KantoRibbonsParty", {
    new = function(game)
      local rows = {}
      for _, mon in ipairs(game.save.party or {}) do
        rows[#rows + 1] = {
          label = monLabel(mon),
          right = tostring(ribbonCount(mon)),
          value = mon,
        }
      end
      return mod.ui.ListMenu.new(game, "RIBBONS", rows, {
        onChoose = function(item)
          mod.ui.push(game, "KantoRibbonsDetail", item.value)
        end,
      })
    end,
  })

  local Font = mod.ui.Font
  -- Reached under the same engine_internals permission as the
  -- SummaryMenu patch below. Only ever READ from (uiSize), never
  -- configured -- Game:draw owns setUISize and calls it from this
  -- screen's own uiSize() return value.
  local Renderer = require("src.render.Renderer")
  local PaletteFX = require("src.render.PaletteFX")

  -- lazy: mod.assets:image needs a graphics context, which a headless
  -- load (tests, validate) doesn't have. Loaded once, on first draw.
  -- One 288x16 sheet, eighteen 16x16 cells in catalog order -- a single
  -- image load and one quad table no matter how many ribbons get added,
  -- rather than one newImage call per ribbon.
  local ICON_SIZE = 16
  local ribbonSheet, ribbonQuads
  local function sheet()
    if ribbonSheet == nil then
      local ok, img = pcall(function()
        return mod.assets:image("ribbons.png")
      end)
      ribbonSheet = ok and img or false -- false = tried and failed
      if not ok then
        mod.log:warn("ribbons.png failed to load (%s) -- drawing " ..
          "ribbon rows without icons", tostring(img))
      elseif img then
        ribbonQuads = {}
        local w, h = img:getDimensions()
        for i = 1, #catalog do
          -- a sheet shorter than the catalog gets quads only for the
          -- cells that exist; the rest draw text-only rather than
          -- sampling past the edge
          if i * ICON_SIZE <= w then
            ribbonQuads[i] = love.graphics.newQuad(
              (i - 1) * ICON_SIZE, 0, ICON_SIZE, ICON_SIZE, w, h)
          end
        end
      end
    end
    return ribbonSheet or nil
  end

  -- Up/Down scroll the owned list one row at a time; A or B closes.
  -- WINDOW_SIZE rows visible at once fits the standalone screen's box
  -- (32..142) at this row pitch: 4*27 = 108px, comfortably inside 110.
  --
  -- This scrolls rather than pages in fixed chunks of 3 (the previous
  -- design) because a mod called G1R HoldToScrollUI by WizzStar
  -- (github.com/WizzStar/PKMN-G1R-HoldToScrollUI-Mod) showed the
  -- pattern worth adopting: it auto-repeats a held D-pad direction by
  -- injecting synthetic wasPressed edges through an `input.step` hook
  -- for any screen that polls ordinary directional input. No dependency
  -- is taken here -- this screen just polls plain wasPressed("up"/
  -- "down") like any other menu, so if a player also has that mod
  -- installed, holding the D-pad auto-repeats here for free; without
  -- it, normal repeated taps scroll one row each. Credited in
  -- THIRD_PARTY_NOTICES.md for the interaction design.
  local WINDOW_SIZE = 4
  local ROW_H = 27
  local DESC_DY = 16 -- below the 16px icon, not across it

  -- Layout is left-aligned and measured, not eyeballed. The icon sits at
  -- the left margin, the name runs beside it, and the description gets
  -- its own line underneath.
  --
  -- The canvas is no longer assumed to be 160px. A state on top of the
  -- stack may expose uiSize(), and Game.lua:432-433 hands whatever it
  -- returns to Renderer:setUISize before anything draws -- so this screen
  -- can ask for the engine's wide surface. 304x144 is not invented here:
  -- it is WideBattle.WIDTH/HEIGHT (src/battle/WideBattle.lua:22-23), the
  -- same canvas the wide battle layout already uses, so a player who runs
  -- wide sees one consistent width across the game.
  --
  -- `screenW` is re-read from the renderer at the top of every draw
  -- rather than assumed, because setUISize CLAMPS: a request outside
  -- 160..640 silently becomes 160x144 (Renderer.lua:197-201). Reading
  -- back what we actually got means the layout is correct even when the
  -- request was refused, instead of drawing a 304-wide screen into a
  -- 160-wide surface.
  local CLASSIC_W, CLASSIC_H = 160, 144
  local WIDE_W, WIDE_H = 304, 144
  local screenW, screenH = CLASSIC_W, CLASSIC_H
  local MARGIN = 4
  local ICON_W = 16
  local NAME_X = MARGIN + ICON_W + 4 -- 24
  -- Descriptions sit in the SAME column as the name, not flush against
  -- the left margin. Reported from device as the layout looking like it
  -- "tilts": with the name indented past the icon and the description
  -- jutting back out to x=4, the left edge stepped in and out down the
  -- screen. One column reads straight. Costs 20px of description width
  -- (152 -> 132, i.e. 16 characters), which is why every description
  -- was shortened to fit in 0.15.3.
  local DESC_X = NAME_X
  -- Every left edge on this screen is one of exactly two values: MARGIN
  -- for the icon gutter and anything with no icon beside it, and NAME_X
  -- for the text column. 0.15.4 still drew the header at x=8 and the
  -- empty-state line at x=16 -- neither matched anything else, so the
  -- screen had four left edges (4, 8, 16, 24) and still read as tilted
  -- even after the description column was fixed in 0.15.3. The header is
  -- the worst offender because the scroll indicator opposite it IS
  -- anchored to MARGIN (right edge 156), so the top row was visibly
  -- lopsided: 8 in from the left, 4 in from the right.
  local TITLE_X = MARGIN
  local EMPTY_X = MARGIN

  -- Truncation is by measured pixel width via Font.width, so a long
  -- string is structurally unable to overflow no matter what a future
  -- ribbon's text says -- rather than relying on every description
  -- being hand-checked against the margin.
  local function clipToWidth(text, x)
    local budget = screenW - x - MARGIN
    if Font.width(text) <= budget then return text end
    local out = text
    while #out > 1 and Font.width(out .. "..") > budget do
      out = out:sub(1, #out - 1)
    end
    return out .. ".."
  end

  -- Names degrade instead of clipping mid-word. On real hardware the
  -- full "Hall of Fame Ribbon" overflowed and clipToWidth rendered it
  -- "Hall of Fame R..", which is uglier and no more informative than
  -- just dropping the suffix. So: try "<short> Ribbon", fall back to
  -- "<short>" alone, and only clip if even that won't fit. The suffix is
  -- the redundant part on a screen already titled RIBBONS, so it's the
  -- right thing to lose first.
  local function fitName(def, x)
    local budget = screenW - x - MARGIN
    local base = def.short or def.name
    local full = base .. " Ribbon"
    if Font.width(full) <= budget then return full end
    if Font.width(base) <= budget then return base end
    return clipToWidth(base, x)
  end

  local function ownedRibbons(mon)
    local owned = {}
    for i, r in ipairs(catalog) do
      if hasRibbon(mon, r.id) then owned[#owned + 1] = { def = r, cell = i } end
    end
    return owned
  end

  -- Draws rows [scroll+1 .. scroll+WINDOW_SIZE] of the owned list.
  -- Returns how many rows were drawn and the owned total, so the caller
  -- can show an empty state or a scroll-position indicator.
  local function drawRibbonWindow(mon, topY, scroll)
    local img = sheet()
    local owned = ownedRibbons(mon)
    local shown = 0
    for i = scroll + 1, math.min(scroll + WINDOW_SIZE, #owned) do
      local entry = owned[i]
      local y = topY + shown * ROW_H
      local quad = ribbonQuads and ribbonQuads[entry.cell]
      if img and quad then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(img, quad, MARGIN, y)
      end
      love.graphics.setColor(0, 0, 0, 1)
      -- Full "<Name> Ribbon" per row now, not just the short label.
      -- clipToWidth is the safety net for the three longest (Hall of
      -- Fame, Best Friends, Gorgeous Royal) -- this sandbox has no real
      -- ROM font to measure against (fixtures are missing lowercase
      -- glyphs entirely), so those three specifically are worth a
      -- real-device look: either they fit, or they clip to ".." cleanly
      -- rather than running off-screen either way.
      Font.draw(fitName(entry.def, NAME_X), NAME_X, y + 4)
      Font.draw(clipToWidth(entry.def.description, DESC_X), DESC_X, y + DESC_DY)
      shown = shown + 1
    end
    return shown, #owned
  end

  -- The standalone screen (Modern UI path, and the party overview's
  -- drill-down). Self-drawn rather than a ListMenu so it renders the
  -- same icons and descriptions as the nested page.
  mod.content.screens:register("KantoRibbonsDetail", {
    new = function(game, mon)
      local state = { game = game, isOpaque = true, scroll = 0 }
      local total = #ownedRibbons(mon)
      local maxScroll = math.max(0, total - WINDOW_SIZE)

      function state:update()
        local input = game.input
        if not input then return end
        if input:wasPressed("up") then
          self.scroll = math.max(0, self.scroll - 1)
        elseif input:wasPressed("down") then
          self.scroll = math.min(maxScroll, self.scroll + 1)
        elseif input:wasPressed("a") or input:wasPressed("b") then
          game.stack:pop()
        end
      end

      -- Whether the wide canvas is wanted is decided ONCE, here, and the
      -- uiSize/sgbPalettes methods are only INSTALLED when it is.
      --
      -- That is not tidiness, it is the fix for a real regression in
      -- 0.19.0/0.20.x. Game:draw picks the screen's palette by walking
      -- DOWN the stack and stopping at the first state that has an
      -- sgbPalettes method at all (Game.lua:488-495) -- "the topmost
      -- state that knows its palette owns the screen (overlays like text
      -- boxes inherit from what's beneath them)". This screen never had
      -- one, so the search fell through to the overworld underneath and
      -- this screen INHERITED its colour zones. That inheritance is where
      -- the ribbon icons' colour has always come from.
      --
      -- Defining sgbPalettes unconditionally stopped that search here.
      -- Returning nil from it then meant no zones at all, so ADVANCED and
      -- the other colour modes drew the whole screen in flat greyscale --
      -- reported from device. Merely HAVING the method is the side
      -- effect; what it returns is secondary.
      --
      -- So when the option is off, this state carries neither method and
      -- is byte-for-byte the 0.18.0 state object. Only the wide path,
      -- which genuinely must own its palette, installs them.
      --
      -- pcall'd and defaulted: an options read that throws must leave the
      -- screen on the classic path rather than take it down.
      local okOpt, wantWide = pcall(function()
        return mod.options:get("wide_screen")
      end)
      wantWide = okOpt and wantWide or false

      if wantWide then
        -- Asked for BEFORE anything draws: Game:draw resolves the top
        -- state's surface every frame (Game.lua:432-433), so returning
        -- the wide size here is what widens the canvas.
        function state:uiSize()
          return WIDE_W, WIDE_H
        end

        -- Widening the canvas moves the SGB colorization pass out from
        -- under the screen, so the wide path has to own its palette.
        --
        -- A state exposing no zones normally gets one invented for it,
        -- but PaletteFX.whole() is hardcoded to tiles (0,0)-(19,17)
        -- (PaletteFX.lua:284-286) -- exactly 160x144. On a 304-wide
        -- canvas that remap stops dead at x=160 and leaves the right half
        -- untouched in the three forced-mono COLORS modes (OG / OG INV /
        -- CLASSIC). BattleState.lua:122-126 documents the same trap for
        -- the wide battle, which is why WideBattle ships zones() at all.
        function state:sgbPalettes()
          local w, h = self:uiSize()
          local mode = PaletteFX.mode or "gbc"
          if mode == "og" or mode == "og_inv" or mode == "classic" then
            return { PaletteFX.zone(PaletteFX.GRAYS, 0, 0, w / 8 - 1, h / 8 - 1) }
          end
          -- Colour modes: a full-canvas passthrough zone, the shape
          -- WideBattle.zones() uses for the same case. NOT nil -- nil
          -- here would strip colour exactly the way the 0.19.0
          -- regression did, since this method's presence has already
          -- ended Game.lua's search for a palette owner.
          return { { colors = false, x = 0, y = 0, w = w, h = h } }
        end
      end

      function state:draw()
        -- Read back the surface we actually got rather than the one we
        -- asked for. setUISize clamps a request outside 160..640 to the
        -- classic size without saying so, and other things (a wide
        -- battle underneath) can own the surface instead -- in either
        -- case the layout below has to follow the real width.
        local okSize, w, h = pcall(function()
          return Renderer:uiSize()
        end)
        screenW = (okSize and type(w) == "number") and w or CLASSIC_W
        screenH = (okSize and type(h) == "number") and h or CLASSIC_H

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)
        love.graphics.setColor(0, 0, 0, 1)
        -- The indicator is measured FIRST so the title can be clipped
        -- against the space it actually leaves. A 10-character nickname
        -- (80px) and the widest indicator ("14-17/17", 64px) come to
        -- exactly 156 with the margins -- i.e. they just fit today, with
        -- nothing to spare. Rather than leave the top row depending on
        -- that coincidence, the title yields.
        --
        -- position within the OWNED list only -- never a hint about
        -- ribbons not yet earned.
        -- Right-aligned by MEASURED width: this used to draw at a
        -- hardcoded x=108, which fit "1-4/17" but ran off the edge
        -- once the numbers got wider ("14-17/17" is 64px and ended at
        -- 172, past the 156 margin). Anchoring to the right margin
        -- keeps it inside no matter how many ribbons exist.
        local label
        if total > WINDOW_SIZE then
          label = ("%d-%d/%d"):format(self.scroll + 1,
            math.min(self.scroll + WINDOW_SIZE, total), total)
        end
        local titleBudget = screenW - MARGIN - TITLE_X
        if label then
          titleBudget = titleBudget - Font.width(label) - 4
        end
        local title = mon and monLabel(mon) or "RIBBONS"
        if Font.width(title) > titleBudget then
          title = clipToWidth(title, screenW - MARGIN - titleBudget)
        end
        Font.draw(title, TITLE_X, 4)
        if label then
          Font.draw(label, screenW - MARGIN - Font.width(label), 4)
        end
        local shown = drawRibbonWindow(mon, 20, self.scroll)
        if shown == 0 then
          love.graphics.setColor(0, 0, 0, 1)
          Font.draw("No ribbons yet.", EMPTY_X, 64)
        end
      end

      return state
    end,
  })

  -- THE way ribbons open, in every UI: chained into the status screen's
  -- own page cycle, so A reads STATS -> MOVES -> RIBBONS -> close with no
  -- menu entry anywhere. The stock summary screen exposes no hook, so
  -- this patches SummaryMenu.update at runtime -- input still flows
  -- through the native state even under gen1_modern_ui's replacement
  -- drawing, which is why one patch covers both UIs (and why no engine
  -- file edit or separate engine zip is needed). engine_internals is
  -- declared for exactly this; Snag Quest's BattleState.throwBall patch
  -- is the precedent. `self.pageCount or 2` keeps it correct on a stock
  -- two-page screen and on any engine where other mods add pages.
  local SummaryClass = require("src.ui.SummaryMenu")
  local vanillaSummaryUpdate = SummaryClass.update
  SummaryClass.update = function(self, dt)
    local input = self.game and self.game.input
    local last = self.pageCount or 2
    if input and (self.page or 1) >= last
        and (input:wasPressed("a") or input:wasPressed("b")) then
      local game, mon = self.game, self.mon
      game.stack:pop()
      mod.ui.push(game, "KantoRibbonsDetail", mon)
      return
    end
    return vanillaSummaryUpdate(self, dt)
  end

  -- and a whole-party overview, for checking everyone without backing
  -- out to the party menu each time
  mod.hooks:wrap("ui.start_menu.items", function(next, game, items)
    local out = next(game, items)
    if type(out) ~= "table" then return out end
    return mod.ui.insertBefore(out, "SAVE", {
      label = "RIBBONS",
      onSelect = function() mod.ui.push(game, "KantoRibbonsParty") end,
    })
  end)
end
