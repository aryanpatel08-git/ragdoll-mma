# Base code handoff — November 19, 2026

> Historical foundation snapshot. The scripts were subsequently applied to Studio and fighter allocation moved to LobbyService. See [current lobby status](lobby-status.md).

Source of requirements: the newer **Ragdoll MMA – Task List** and **Styles & Task Tracker** supplied on November 19. Their four resources (Health, Body, Stamina, Guard), left/right strike inputs, six-cage target and 3×60-second round specification supersede conflicting older design notes. The 60-task tracker has not been edited or marked complete.

## Implemented foundation

- `FoundationConfig`: movement and camera tuning.
- `Foundation.server`: assigns the first two connected players to the prototype cage, positions them on respawn and updates opponent IDs. Extra players wait outside the fighter pair; leaving frees the slot.
- `FightCamera.client`: AlignOrientation opponent-facing and a smoothed camera framing both fighters. Returns to Roblox's ordinary camera and AutoRotate when no opponent exists.
- `CombatConfig`: four strike definitions, costs/timings/ranges, damage, four resource maxima, guard tuning; future round constants are data only.
- `CombatService` + `CombatBootstrap`: validates intent names/types and rate limits, enforces cooldown and stamina, resolves the assigned opponent, checks forward direction/range and arena bounds, then checks a server spatial overlap. Damage and body depletion are server-owned. Guard reduces frontal damage, drains on hold/hit and breaks into a short stun. Low body slows stamina regeneration.
- `CombatInput.client`: Q/E punches, Z/C kicks, F hold guard; controller bindings and provisional ContextActionService touch buttons. Normal movement/jump stay available.
- `CombatHUD.client`: mirrored Health/Body/Stamina/Guard displays plus opponent and prototype status.
- `tools/build-arena.luau`: reproducible Edit-mode arena builder. Already run in MMA Dev; it refuses to replace an existing MMAFoundation.

## Intentional limits

This is the first combat skeleton, not a completed fight. No published animation IDs or hit effects are supplied. The strikes currently apply after a configurable windup without an attack animation. Damage zones are simplified move categories rather than per-limb collision precision. Humanoid death at zero health is temporary: task F16's count-and-recovery has not been built. No rounds, winner/results/rematch state machine, ragdolls/get-up, dodge/counter, grab/submission, kick catch, combo finisher, weight/reach variants, styles framework, progression, purchases or saves are implemented. Seven-action mobile layout is unfinished; only implemented actions have buttons. No multiplayer, touch/gamepad, performance or balance pass has been completed. Server checks are a foundation, not complete movement/teleport anti-cheat.

## Sync and verification

1. Open MMA Dev (place 74547971656749). It already contains Workspace.MMAFoundation.
2. Coordinate with the current Rojo editor before taking over its session lock.
3. Serve this folder's default.project.json and connect Rojo in Studio. Review the incoming script additions before accepting. Do not sync an outdated teammate checkout.
4. Run Studio Clients and Servers with two R15 players. Check assigned corners, camera/facing, Q/E/Z/C costs and hits, frontal guard vs rear attacks, low-body stamina regeneration, player departure/respawn and rejected attacks outside the cage.
5. Treat the Step 1/2 gates as pending until a real two-client playtest succeeds. Build F14–F18 next before calling this a playable match.

Checks completed locally: StyLua 2.6.0 parsed/formatted all Luau; Rojo 7.7.1 built the project successfully. Live Studio inspection showed no synced scripts at the end of this task. The source code is ready in the local Rojo checkout; only arena geometry has been applied live.

Undo geometry: remove only Workspace.MMAFoundation. Undo code: remove/revert only the newly added source files and review Rojo's resulting patch.
