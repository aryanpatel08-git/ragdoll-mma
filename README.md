# Ragdoll MMA

A Roblox multiplayer MMA brawler: responsive 1v1 cage fights with ragdoll knockouts, in a gym lobby of 10–15 players with 6 cages.

**Player promise:** Easy to learn. Rewarding to master. Funny to watch.

## Where things live

| What | Where |
| --- | --- |
| The game | Roblox experience **MMA Dev** (place ID `74547971656749`), owned by YUP, edited together in Team Create |
| Design doc | [docs/design-doc.md](docs/design-doc.md) |
| Step-by-step build plan | [docs/build-steps.md](docs/build-steps.md) |
| Scripts (once we start coding) | [src/](src/), synced into Studio with Rojo |

## Status

Step 0 (setup). The place is still an empty Baseplate: no scripts or models yet.

## Project layout

```text
docs/            design doc and build steps
src/server/      → ServerScriptService.Server   (server systems: combat, matches, lobby, saving)
src/client/      → StarterPlayer.StarterPlayerScripts.Client   (input, camera, UI)
src/shared/      → ReplicatedStorage.Shared     (config, shared types, RemoteEvents setup)
default.project.json   Rojo mapping from src/ to the Roblox place
```

## Working on the game

1. Ask YUP for Edit access to MMA Dev (you must be Roblox friends with YUP).
2. Open MMA Dev from Roblox Studio and edit together in Team Create.
3. Before changing a system, check [docs/build-steps.md](docs/build-steps.md) for which step it belongs to and who owns it.
4. Commit design changes to `docs/` so the repo stays the team's record.

## Contributing

- Work on a branch, open a pull request, and get one teammate to look before merging into `main`.
- Keep one ModuleScript per system so two people rarely edit the same script.
- The server decides every hit, reward and purchase; never trust values sent by a client.
