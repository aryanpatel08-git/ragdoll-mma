# Build Steps

Snapshot of the team's "Build Steps" tab, Nov 19, 2026. Section numbers refer to [design-doc.md](design-doc.md).

Build Ragdoll MMA in Roblox Studio one step at a time: finish a step, check its "Done when" line, then move on. Each step names the design-doc section it comes from, and a Roblox Studio line lists the tools to use. Don't start a phase until the one before it passes its gate.

## Step 0 — Setup before any code

Focus: agree on the basics so nobody builds in the wrong direction.

- [ ] Engine: Roblox Studio, scripted in Luau. Pick the devices you'll support (PC, controller, mobile).
- [ ] YUP owns the experience: YUP turns on Team Create and gives each teammate Edit access (teammates must be Roblox friends with YUP), so everyone edits the same place, and agree on a folder layout (combat, match, lobby, UI, progression).
- [ ] Write down the smoothness target: frame rate and the weakest device you must run on.
- [ ] Assign an owner for each phase below (design doc section 12).

**Roblox Studio:** In Game Settings, set max players to 15. Put server logic in ServerScriptService, shared ModuleScripts and RemoteEvents in ReplicatedStorage, client scripts in StarterPlayerScripts, and assets in ServerStorage. One ModuleScript per system keeps owners from editing the same script. Optional: Rojo + GitHub if the team wants real version control.

**Done when:** everyone can open the same empty project and knows what they own.

## Phase 1 — The core fight

Goal: two players in one plain arena having a fun fight. No lobby, no rewards, no cosmetics yet.

### Step 1 — One fighter that moves well

- [ ] Character with walk, turn, and always facing the opponent's direction.
- [ ] Camera that frames the fight.
- [ ] One plain arena with walls (sections 9, 11 Stage A).

**Roblox Studio:** Start from the default R15 character. Turn off Humanoid.AutoRotate and use an AlignOrientation to face the opponent. Script the fight camera in a LocalScript.

**Done when:** moving feels instant and smooth with no fighting at all.

### Step 2 — Two players online

- [ ] Second player joins the same arena over the network.
- [ ] Movement syncs with no visible rubber-banding.
- [ ] Decide what the server owns (hits, health, results) vs. what each player predicts locally (movement, animations) (section 12).

**Roblox Studio:** Roblox replicates character movement for you. Test with Test → Clients and Servers (2 players). From here on, every fight action is a RemoteEvent from client to server; the server never trusts what the client says happened.

**Done when:** two people on different machines can walk around each other smoothly.

### Step 3 — Punching and health

- [ ] Light punch and heavy punch with animations.
- [ ] Hit detection checked by the server.
- [ ] Health bars and damage (section 3).

**Roblox Studio:** Make attacks in the Animation Editor and play them as AnimationTracks. The client fires an attack RemoteEvent; the server checks cooldown and range, finds hits with a spatial query (e.g. GetPartBoundsInBox), and applies damage.

**Done when:** you can punch the other player and their health drops, and both screens agree.

### Step 4 — Defense and stamina

- [ ] Block and dodge.
- [ ] Counter window after a successful dodge.
- [ ] Stamina bar that limits attacks and dodges; exhaustion makes you vulnerable.

**Roblox Studio:** Keep health, stamina and balance on the server as attributes on the character (SetAttribute); the UI listens for attribute changes.

**Done when:** spamming attacks loses to someone who blocks, dodges, and counters.

### Step 5 — Ragdolls and balance

- [ ] Balance meter.
- [ ] Reactions: small recoil, stumble, full knockdown, get up, knockout tumble (section 3).
- [ ] Smooth switch from animation to ragdoll and back.

**Roblox Studio:** Ragdoll by swapping the character's Motor6D joints for BallSocketConstraints and setting the Humanoid to the Physics state; reverse it to get up. Decide who owns the ragdoll's physics (BasePart:SetNetworkOwner) and test for jitter on both screens.

**Done when:** a big counter on a tired fighter sends them flying, and getting up takes a short, predictable time.

### Step 6 — Match flow

- [ ] Countdown, roughly two-minute timer, knockout win, and time-out score (section 4).
- [ ] Quick results screen and one-button rematch.

**Roblox Studio:** One server ModuleScript runs a match's state (countdown, fighting, results). Build the countdown and results screens as ScreenGuis.

**Done when:** two players can fight, see a winner, and rematch without restarting the game.

**Phase 1 gate:** would the team voluntarily play ten fights in a row with no rewards? If not, stay in Phase 1 and fix the fight.

## Phase 2 — Make it feel good

Goal: the fight from Phase 1 plays well on every device and feels punchy.

### Step 7 — Controls on every device

- [ ] Keyboard, controller, and touch layouts using the same six inputs (light, heavy, kick, block, dodge, grab).
- [ ] Touch buttons sized and placed for thumbs.

**Roblox Studio:** Bind each action once with ContextActionService. It covers keyboard and gamepad and can create on-screen touch buttons. Check layouts with Studio's Device Emulator.

**Done when:** a new player can fight on each device without reading instructions.

### Step 8 — Kicks and takedowns

- [ ] Kick with range control and a punishable miss.
- [ ] Grab/takedown, escape, and return to standing (no ground game yet).

**Done when:** kicks and takedowns add choices without making the fight confusing. Re-run the ten-fights test.

### Step 9 — Hit feel and polish

- [ ] Punch sounds, distinct block/clean-hit/counter feedback, brief impact pause on big hits (section 7).
- [ ] Visible exhaustion and wobbly balance.
- [ ] Knockout camera.
- [ ] Settings to reduce camera shake and effects.

**Roblox Studio:** Sounds and ParticleEmitters for hits; camera shake and impact pauses run in a LocalScript, so they never slow the server.

**Done when:** people laugh at knockouts and can always tell why they got hit.

**Phase 2 gate:** the fight hits the smoothness target from Step 0 on the weakest supported device.

## Phase 3 — The gym lobby

Goal: players spawn into a gym and walk up to a cage to fight (section 6).

### Step 10 — Lobby with one cage

- [ ] Spawn point in the lobby.
- [ ] Walk up to the cage to join or challenge; cage light shows open, waiting, or in a fight.
- [ ] After a match, walk out back into the lobby (or rematch).

**Roblox Studio:** A SpawnLocation in the lobby; a ProximityPrompt at each cage door to join or challenge; a server module tracks who is in or queued for each cage.

**Done when:** two players can spawn, walk to the cage, fight, and return to the lobby.

### Step 11 — Six cages and the punching bag area

- [ ] Copy the cage to 6 cages arranged around spawn, each running its own match.
- [ ] Cage queue and quick-play button that sends you to the next free cage.
- [ ] Punching bag area and combo dummy next to spawn.
- [ ] Spectator spots around cages.
- [ ] Lobby holds at least 10–15 players.

**Roblox Studio:** Make one cage a Model and copy it six times, each run by its own instance of the match module. Check performance with the Developer Console (F9) and the MicroProfiler, and test a full lobby in a private-server playtest with real players on phones.

**Done when:** a full 15-player lobby, with all 6 cages fighting at once, still hits the smoothness target.

## Phase 4 — First release

Goal: a complete, reliable game people can play and come back to.

### Step 12 — Saving and reliability

- [ ] Save player data (level, cosmetics, currency) and load it on join.
- [ ] Handle disconnects mid-fight, interrupted matches, and players leaving a cage (section 12).

**Roblox Studio:** Save with DataStoreService: wrap every call in pcall, save on PlayerRemoving and in game:BindToClose. Turn on Studio access to API services in Game Settings to test saves. Free a player's cage in PlayerRemoving.

**Done when:** quitting mid-fight never breaks the cage or loses anyone's progress.

### Step 13 — Cosmetics and earned progression

- [ ] Account level and rewards for finishing matches, extra for winning (section 8).
- [ ] A small set of gloves, shorts, and poses.
- [ ] Changing area in the lobby.

**Roblox Studio:** Store owned and equipped cosmetic IDs in the DataStore; build gloves and shorts as Accessories or meshes attached to the character.

**Done when:** players earn and equip a cosmetic within their first few fights.

### Step 14 — Shop menu

- [ ] Shop menu from the HUD and a shop counter in the lobby.
- [ ] Direct cosmetic purchases only; nothing that affects combat (section 10).

**Roblox Studio:** Sell with MarketplaceService: Developer Products for repeat purchases (grant them in ProcessReceipt and save right away), Game Passes for one-time unlocks. Prices are in Robux.

**Done when:** a player can buy and equip a cosmetic, and it saves.

### Step 15 — Friends and onboarding

- [ ] Friend challenges to a specific cage.
- [ ] Short tutorial ring for new players.

**Roblox Studio:** SocialService:PromptGameInvite to bring friends in; Player:IsFriendsWith to show friends first in the challenge list.

**Done when:** a brand-new player learns the basics and fights a friend in under five minutes.

**Phase 4 gate — first milestone:** two players spawn, walk to a cage, have a fair, funny fight, and rematch, on every supported device. Release, then collect feedback.

## Phase 5 — Spins and expansion

Goal: add depth one system at a time, guided by player feedback. Finish and playtest each step before the next.

### Step 16 — Spin system and the first fighting style

- [ ] Earn spins from matches and milestones.
- [ ] Spin screen and saved unlocks.
- [ ] One style (e.g. boxing) that swaps moves behind the same inputs (section 3).

**Roblox Studio:** Roll spins on the server only (Random.new()) and save the result before showing the animation, so leaving mid-spin never loses or duplicates a reward.

**Done when:** the first style feels different but wins about as often as the shared moveset.

### Step 17 — More styles and upgrades

- [ ] Add kickboxing, wrestling, judo one at a time, each with a rarity tier.
- [ ] Style skill upgrades earned by counters, takedown escapes, and training.

**Roblox Studio:** One ModuleScript of move data per style (damage, stamina cost, timing), so balancing is editing numbers, not code.

**Done when:** no style dominates win rates in playtests.

### Step 18 — Height and weight spins

- [ ] Shared height/weight spin, usable on either trait.
- [ ] Trade-offs shown before confirming; switch between unlocked builds in the changing area.

**Roblox Studio:** Scale R15 fighters with the Humanoid's body scale values (BodyHeightScale, BodyWidthScale, BodyDepthScale), and scale hitboxes and reach to match.

**Done when:** tall/short and heavy/light fighters each win and lose for understandable reasons.

### Step 19 — Nationality

- [ ] Flag, name plate, and walkout banner (cosmetic only); settle spin vs. free pick first.

**Roblox Studio:** A BillboardGui name plate with the flag, and the flag on the walkout banner.

**Done when:** players can show a nationality in the lobby and walkout.

### Step 20 — Cosmetic packs

- [ ] Themed packs with odds shown and duplicate protection.
- [ ] Check platform rules before selling packs for real money.

**Roblox Studio:** If packs can be bought with Robux, directly or with currency bought with Robux, Roblox's paid random items policy applies: show the numerical odds of every outcome before purchase; check PolicyService (ArePaidRandomItemsRestricted) and block paid packs for players where it is true; declare them in the Maturity & Compliance Questionnaire; and items from paid packs can't be traded for value. Earn-only packs avoid all of this. [Policy](https://create.roblox.com/docs/production/monetization/paid-random-items)

**Done when:** every pack shows its odds and repeat rolls always make progress.

### Step 21 — New modes and arenas

- [ ] Pick one at a time: party free-for-all, ranked, fight nights, silly modes, tag team, new arenas, replays (section 5).

**Roblox Studio:** Party and ranked modes can be separate places in the same experience, reached with TeleportService, so their rules never mix with casual 1v1.

**Done when:** the new mode passes its own playtest without hurting casual 1v1.
