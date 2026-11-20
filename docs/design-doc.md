# Ragdoll MMA – Game Design Doc

Snapshot of the team design doc, Nov 19, 2026. The live version is the Claude doc "Ragdoll MMA – Game Design Doc"; update this file when that changes.

## The idea in 30 seconds

A stylized multiplayer MMA brawler where responsive combat meets ragdoll physics. Players spawn into a gym lobby, walk up to one of the server's cages, and fight short 1v1 bouts. They dodge, counter, manage stamina, and knock opponents off balance. Big hits create funny, memorable knockouts; good timing and decisions decide who wins.

Beyond the shared starter moveset, players earn spins through matches and milestones. Spins unlock fighting styles (boxing, kickboxing, wrestling, judo and more), fighter builds (height and weight), a fighter nationality, and cosmetic packs. Each style has a rarity tier, distinctive moves or visual flair, and clear strengths and trade-offs. Rarer means less common and more distinctive, not automatically stronger.

Players develop their unlocked styles through training and meaningful match play, such as landing counters or escaping takedowns. Upgrades unlock options and specialization while keeping fights fair, so players experiment, master a style, and return without paid combat power.

**Player promise:** Easy to learn. Rewarding to master. Funny to watch.

**Main hook:** Land a skillful hit and get an exaggerated physical payoff.

**Platform:** Roblox, built in Roblox Studio and scripted in Luau. Each lobby is a Roblox server of 10–15 players; purchases are in Robux.

This is a proposed design, not a guarantee of fun. Use playtests to decide what stays. The full feature vision below is not the launch checklist.

## 1. The experience

You spawn into a gym lobby with friends. You warm up on a punching bag, try a combo you just unlocked, then walk up to an open cage and challenge someone. Inside the cage, you dodge a heavy punch, counter, and make them stumble. They recover and attempt a takedown. You escape with little stamina remaining, create space, and land a finishing kick that sends them tumbling.

A quick results screen shows your performance, any spins earned, and cosmetic progress. One button starts the rematch; walking out of the cage returns you to the lobby.

**Core loop:** Spawn → walk to a cage → fight → pull off a satisfying move → earn progress and spins → customize → rematch.

The fight itself must be the main reward. Progression adds reasons to return.

## 2. Design rules

- **Control first:** Normal movement stays responsive. Ragdolls activate on meaningful impacts, takedowns, and knockouts.
- **Smooth above all:** The game must feel smooth: a stable frame rate, input that responds instantly, and no visible rubber-banding between players. A feature that breaks smoothness on a supported device is cut or simplified.
- **Skill matters:** Timing, spacing, defense, and stamina management beat attack spam.
- **Fast return to action:** Short recovery, brief results screens, and easy rematches.
- **Fair progression:** Earn expression and status, not stronger punches. Spun traits (style, height, weight) are sidegrades with trade-offs, never straight upgrades.
- **Readable chaos:** Funny physics should not hide what happened or why.
- **Small, polished foundation:** Make one arena and one moveset enjoyable before expanding.

## 3. Combat

Keep inputs manageable on touchscreens, keyboard, and controller. Introduce depth through timing and decisions rather than many buttons.

### Actions and trade-offs

| Action | Strength | Weakness |
| --- | --- | --- |
| Light punch | Fast pressure and short combinations | Low damage; predictable when repeated |
| Heavy punch | Strong impact and knockdown potential | Slow windup, high stamina cost, punishable misses |
| Kick | Controls distance | Leaves an opening if it misses |
| Block | Reduces damage | Sustained pressure can break the defense |
| Dodge | Avoids a strike and opens a counter | Costs stamina and requires timing |
| Grab / takedown | Punishes close, defensive opponents | Can be interrupted or escaped |
| Get up | Returns a knocked-down fighter to control after a short recovery | — |

Start with a few readable combinations, such as two light punches into an uppercut. Avoid long sequences that prevent the opponent from responding.

### How fighting styles change controls

Each skill set changes what the buttons do, not where they are. Every style keeps the same input layout (light, heavy, kick, block, dodge, grab), so players never relearn the controller and touch layouts stay simple. The style swaps the move behind each input and its timing:

- **Boxing:** heavy becomes a hook or uppercut, dodge becomes a quick slip with a faster counter window; kicks are weak or replaced by a body shot.
- **Kickboxing:** kick gains range and a spinning variant; slightly slower punches.
- **Wrestling:** grab becomes a stronger, faster takedown; weaker strikes at range.
- **Judo:** grab becomes a throw that uses the opponent's momentum; strong when countering a lunge.

Show each style's move list in the punching bag area and on the pre-fight screen so opponents can read what they are facing.

### Three resources

- **Health:** How close a fighter is to losing.
- **Stamina:** Limits attacks, dodges, and grappling. Exhaustion creates vulnerability.
- **Balance:** Resistance to knockdowns. A heavy counter against an exhausted fighter should have more effect than a light punch against a fresh fighter. Fighter weight (section 8) can shift balance slightly.

Exact damage, costs, recovery times, and regeneration rates are playtest decisions.

### Ragdoll reactions

- **Small hit:** Head or torso recoils; movement remains under player control.
- **Big hit:** Brief stumble or loss of footing.
- **Knockdown:** Full ragdoll with a short, predictable recovery window.
- **Knockout:** Exaggerated final tumble and a clear match result.

Do not leave players helpless for long periods. Physics should provide variety without making outcomes arbitrary. Ragdolls must stay smooth on every client: simulate them locally for looks, and let the server decide outcomes.

**Grappling scope:** Begin with short takedown exchanges that return fighters to standing. Full ground fighting and submissions are a later possibility, not part of the initial build.

## 4. Match format

- **Main mode:** Casual 1v1 cage fights, started by walking up to a cage in the lobby.
- Target roughly two-minute matches as a starting point to test.
- A knockout ends the fight.
- If time expires, use a clearly explained score based on damage and successful takedowns. Define weights and ties before implementation.
- Use a short countdown, quick results, and instant rematch.
- No casual entry fee and no loss of previously earned currency or spins.
- Test a single health bar against a multiple-knockdown format. Choose the simpler format that produces better fights.

## 5. Modes and priorities

### First release

- **Casual 1v1:** The main balanced fighting experience.
- **Friend challenges:** Easily challenge a specific friend at any open cage.
- **Training gym:** Learn movement, attacks, defense, and timing.

### After the core works

- **Party free-for-all:** Four to six players in a deliberately chaotic mode.
- **Ranked 1v1:** Competitive rating and opponents of similar ability, once the player population supports it. Consider weight classes here if spun weight proves hard to balance.
- **Private fight nights:** Small friend tournaments.
- **Rotating silly modes:** Low gravity, oversized gloves, or slippery floors.
- **Tag team:** Fighters take turns and tag out; consider this before unrestricted 2v2.

Keep competitive rules separate from party modifiers so players know what experience they are choosing.

## 6. Gym lobby and social features

Every server is a gym: players spawn into the lobby and walk up to one of 6 cages to fight. The lobby is required, and it should be a compact hangout with a clear route into a fight.

### Layout

- **Spawn point** in the centre, with the 6 cages arranged in a ring or two short rows around it, so no cage is more than a few seconds' walk away.
- **6 arenas per server:** each cage hosts one 1v1 at a time. Lobbies hold at least 10–15 players. A full 15-player lobby fills all 6 cages with 12 fighters, leaving 3 players to queue, spectate, or train at the punching bags.
- **Cage entry:** walk up to a cage to see who is in it, join its queue, or accept a challenge. A light above each cage shows open, waiting, or in a fight.
- **Punching bag area** next to spawn for testing skills: reactive punching bags and a combination dummy where players try newly unlocked styles, upgrades, and builds before a real fight. Show damage and stamina numbers here only.
- **Short tutorial ring.**
- **Cosmetic changing area** and the shop counter (section 10).
- **Spectator spots** around active cages.

### Social

- Clear quick-play and friend-challenge controls, so players who don't want to walk can still jump straight into the next free cage.
- A small selection of spectator cheers and emotes.

Avoid long walks between matches. Spectator extras come after the basic match flow works. A full 15-player lobby with all 6 cages running ragdoll fights at once is a performance risk: test a full server early (section 11).

## 7. What makes players want another match

### Every hit: satisfying feedback

- Immediate punch sounds and visible reactions.
- Distinct feedback for blocks, clean hits, and counters.
- Brief impact emphasis on major hits.
- Readable signs of exhaustion and unstable balance.
- Powerful, understandable knockouts.
- Settings to reduce camera shake and visual effects.

### Every match: momentum

- One-button rematches and little downtime.
- A short recap with a few useful performance stats.
- Visible progress toward the next spin and cosmetic milestones.
- Opponents whose styles and builds encourage different tactics.
- Funny physics moments that players want to share.

### Over time: mastery and identity

- Goals for meaningful skills, such as counters and takedown escapes.
- Friend rivalries, private tournaments, and eventually competitive ranking.
- New cosmetics, packs, and occasional arena variations.

Do not rely on constant popups or tedious grinding. Reward completed matches and meaningful play; rewarding raw punch counts encourages spam and farming.

**Replay feature:** A finishing-hit replay is a later goal. A simple knockout camera is a practical first version.

## 8. Progression and customization

Keep combat power equal. Beginners should be able to compete without buying upgrades. Everything a player can spin for is either cosmetic or a balanced sidegrade.

- **Account level / cosmetic mastery:** Represents participation and achievements.
- **Competitive rating:** Represents ranked performance.

Give useful progress for finishing matches, with an extra reward for winning. Start with one shared moveset; spins arrive once that moveset is fun.

### The spin system

Players earn spins from matches and milestones. There are four things to spin for:

| Spin | What it changes | Effect on combat | Rule |
| --- | --- | --- | --- |
| Fighting style (skill set) | Moveset and what each input does (section 3) | Sidegrade: clear strengths and weaknesses | Rarity tiers; rarer = more distinctive, not stronger |
| Height | Fighter size and reach | Sidegrade: taller = more reach, bigger target and slower recovery | Small range so no height dominates |
| Weight | Fighter bulk | Sidegrade: heavier = more balance and harder hits, more stamina use and slower dodges | Small range; weight classes in ranked if needed |
| Nationality | Flag, name plate, walkout banner, crowd chant | None: cosmetic only | See open question below |

**Height and weight share one spin pool.** A single height/weight spin can be used on either trait, so players choose which one to reroll. Show the trade-offs on screen before they confirm.

Let players keep previous results they have unlocked and switch between them in the changing area, so a bad spin never locks someone into a build they dislike.

### Style skill upgrades

Players improve the skills of styles they have earned through training and match play. Reward meaningful use and mastery, such as landing counters or escaping takedowns. Upgrades add options or specialization while keeping fights fair; avoid paid combat power.

### Cosmetic rolls and packs

Players roll for cosmetics such as finishing-move animations, gloves, shorts, robes, hand wraps, walkouts, victory poses, titles, profile banners, and unobtrusive knockout effects. Group them into themed packs (for example a Street pack or a Champion pack) with different items in each.

- Show the odds for every item in a pack before the player rolls.
- Add a duplicate protection or pity rule so repeat rolls always make progress.
- Packs never contain anything that affects combat.

**Open question — nationality:** Many players will want to represent their own country rather than gamble for it. Consider letting players pick their flag for free and spinning only for rarer flag-themed cosmetics.

## 9. Arenas and visual identity

- **First arena:** One polished gym cage with clear boundaries, strong lighting, a recognizable color scheme, and room to maneuver. All 6 lobby cages use this design at first.
- **Later settings:** Rooftop exhibition cage, neon underground venue, or beach tournament — these can become themed servers or a mix of cage skins in one lobby.
- Keep competitive arena dimensions consistent. Reserve hazards and unusual layouts for party modes.
- **Fighter model (placeholder, Nov 19):** players spawn as a rounded, faceless ragdoll fighter (black hair block, yellow gloves with white cuffs, waistband, shorts, white shoes) built on a standard R15 rig. It's decent for now but will definitely be redesigned later.
- **Tone:** Cartoon sports chaos. Oversized gloves, expressive fighters, exaggerated reactions, and funny recovery animations. Realistic injuries or gore are unnecessary. Height and weight variation should read clearly in silhouette.

## 10. Monetization and the shop menu

Optional purchases support self-expression. The game includes a shop menu, opened from the HUD or the shop counter in the lobby.

### What the shop sells

- Cosmetic bundles and individual cosmetics, sold as Developer Products (repeatable) or Game Passes (one-time).
- Cosmetic packs (section 8), with odds shown on the pack before purchase.
- Walkout animations, finishing-move animations, and victory poses.
- Private-server customization.
- Supporter cosmetics.

### What the shop never sells

- Damage, extra stamina, faster recovery, or superior fighting styles.
- Style, height, or weight spins. These stay earn-only so no one can pay to reroll into a better build.

Keep all effects readable for both players.

**Check before launch:** Roblox's paid random items policy covers any pack bought with Robux, directly or through currency bought with Robux. The game must show the numerical odds of every outcome before purchase, block paid packs for players whose PolicyService result has ArePaidRandomItemsRestricted set, declare them in the Maturity & Compliance Questionnaire, and stop items from paid packs being traded for value. Keeping packs earn-only avoids all of this; direct cosmetic purchases are the safer default.

Source: [Roblox paid random items policy](https://create.roblox.com/docs/production/monetization/paid-random-items)

## 11. Build roadmap

### Stage A — Prove the fight is fun

- One small arena and two players with reliable movement and facing.
- Light attack, heavy attack, block, and dodge.
- Health, stamina, and a basic balance system.
- Hit reactions, knockdowns, recovery, and knockouts.
- Match start, win detection, reset, and rematch.
- Basic keyboard, controller, and touch controls.

**Playtest gate:** Would we voluntarily play ten fights in a row with no rewards? If not, improve fighting before building progression. **Smoothness gate:** the fight holds a stable frame rate and feels responsive on the weakest supported device.

### Stage B — Complete the first release

- Add kicks and short takedowns once the foundation feels good.
- Build the gym lobby: spawn point, walk-up cage entry, punching bag area, and 6 cages per server.
- Add friend challenges and onboarding.
- Add a small cosmetic selection, simple earned progression, and the shop menu (direct cosmetic purchases only).
- Polish sound, effects, interface, and accessibility settings.
- Handle disconnects, respawns, interrupted matches, and saving.
- Test multiplayer reliability and performance on intended devices, including a full 15-player lobby with all 6 cages fighting at once.

### Stage C — Expand using player feedback

Choose among: the spin system (styles first, then height/weight, then nationality), cosmetic packs, party mode, ranked play, tournaments, new arenas, and replay features. Do not build all of them at once. Add each style only once it passes a balance playtest against the shared moveset.

Step-by-step version of this roadmap: [build-steps.md](build-steps.md)

## 12. Portfolio value and team organization

The portfolio goal should improve execution and documentation while keeping the game focused on players.

- **Multiplayer combat:** Responsive local feedback with server validation of hits and outcomes.
- **Ragdoll engineering:** Reliable transitions between animation, physics, and recovery.
- **Code structure:** Separate combat, match flow, lobby and cage management, interface, progression, and spin/shop systems. In Roblox: one ModuleScript per system, server logic in ServerScriptService, shared code and RemoteEvents in ReplicatedStorage, and the server deciding every hit and reward.
- **Reliability:** Correct cleanup for leaving players, interrupted fights, and respawns.
- **Performance:** Document smoothness testing on the devices you support, including a full 15-player lobby.
- **Individual contributions:** Each teammate records what they built, problems solved, and validation.

Possible ownership areas: combat and networking; physics and character systems (including height/weight scaling); arenas, lobby, and presentation; and interface, match flow, progression, spins, and shop. Combine areas based on team size, and agree on interfaces before connecting systems.

For each portfolio, include a short gameplay video, a clear contribution summary, a small architecture explanation, and a few engineering decisions with evidence. The same game can appear in every teammate's portfolio with accurate attribution.

## 13. Decisions for the first team meeting

- [ ] Choose the working name and visual direction.
- [ ] Agree that casual 1v1 is the first mode.
- [ ] Choose the initial moveset and knockout format to prototype.
- [ ] Assign ownership of the first playable systems.
- [ ] Schedule a team playtest before adding progression.
- [ ] Set the smoothness target (frame rate, supported devices) the game must hit.
- [ ] Confirm the lobby layout: spawn point, 6 cages, punching bag area, and a lobby size of at least 10–15 players.
- [ ] Decide how much height and weight can vary, and whether ranked uses weight classes.
- [ ] Decide whether nationality is spun or freely chosen.
- [ ] Decide whether cosmetic packs are earn-only or also sold, after checking platform rules.

**First milestone:** Two players can spawn in the lobby, walk up to a cage, complete a fair, funny fight, and immediately rematch.

## Appendix: where the additional ideas went

| Added idea | Where it now lives |
| --- | --- |
| Spinning for nationality | 8. Spin system (cosmetic only) + open question |
| Lobby where players spawn and walk up to an arena | 1. The experience; 6. Gym lobby |
| 10 arenas per server (now 6 cages, 10–15 players) | 6. Gym lobby layout; 11. Stage B |
| Punching bag area to test skills | 6. Gym lobby layout |
| Spin for height and weight; one spin usable for either | 8. Spin system |
| Spin for skill set | 8. Spin system (merged with fighting-style spins) |
| Different skill sets change controls | 3. How fighting styles change controls |
| Game must be smooth | 2. Design rules; 11. Smoothness gate |
| Roll for cosmetics in packs | 8. Cosmetic rolls and packs; 10. Shop |
| Shop menu | 10. Monetization and the shop menu |
