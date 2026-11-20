# Base combat and lobby status

Applied to MMA Dev (place 74547971656749), November 19, 2026.

## Source and scope

Uses the newer Task List and Styles & Task Tracker: six cages, four fighter resources, left/right punch and kick inputs. Earlier design text describes ten cages and different resources; those values are superseded. No task tracker entries have been marked complete.

## Applied

- Base server-authoritative strikes, guard, resource regeneration, input bindings, fight camera and mirrored HUD.
- LobbyService replaces automatic first-two-player allocation with six independent cage queues. A cage starts a practice bout when two living players join. Quick Play prefers a waiting opponent, then an empty cage. Each player can occupy one queue or bout.
- Cage state signs and lights, open/shut door collision, lobby respawn, leave controls and cleanup on death, departure or respawn. A practice bout currently ends at Humanoid death or departure, then returns fighters to the lobby. Queues resume afterward.
- Combat validation uses each fighter's active cage and local arena bounds rather than the original arena's world coordinates.
- Training props have a proximity-based practice strike that consumes stamina and reports prototype damage. This is not full animation-driven bag combat or combo scoring.
- Gym geometry: central spawn, six cages in two short rows, spectator benches, training area, tutorial mat, shop and changing counters.
- Quick Play, Leave, Cheer and Invite Friends buttons. Shop/Customize panels explain that their later systems are unfinished.

## Reproducing Studio geometry

The source project syncs scripts through default.project.json; it does not sync map instances. tools/build-arena.luau and tools/build-lobby.luau are Edit-mode builder sources, already run in MMA Dev. Both refuse to overwrite their existing top-level model. Preserve those models when syncing code. The original prototype cage remains at the origin; the gym is centered at (200,0,0).

build-lobby disables the old Workspace.SpawnLocation and records its original Enabled value in MMAOriginalEnabled. To undo lobby geometry, remove only MMAGym and restore that original SpawnLocation.Enabled value. Revert the associated source changes too.

## Still unfinished

- Full 3×60-second match flow, scoring, zero-health counts, ragdolls, recovery and rematch results.
- Guided tutorial, finished combo-dummy mechanics, challenge acceptance UI, spectator camera and finalized mobile/controller UI.
- Shop, owned styles/build customization, rewards, purchases and persistence. No Robux purchases or saves are enabled.
- The configured server maximum of 15 has not been changed or confirmed here; set it in Game Settings.
- Fifteen-player/six-cage performance, multiplayer cleanup and device validation.

## Validation

The base source passed StyLua parsing and a Rojo build. Lobby source parsed and built before application. User subsequently requested direct application without playtesting; no lobby runtime or multiplayer check was run. Treat all behavior above as implementation scope, not a passed acceptance gate. Geometry builder reported six cages and 1,112 descendants under MMAGym.
