# Ragdoll MMA

A Roblox multiplayer MMA brawler: responsive 1v1 cage fights with ragdoll knockouts, in a gym lobby of 10–15 players with 6 cages.

**Player promise:** Easy to learn. Rewarding to master. Funny to watch.

## Where things live

| What | Where |
| --- | --- |
| The game | Roblox experience **MMA Dev** (place ID `74547971656749`), owned by YUP, edited together in Team Create |
| Design doc | [docs/design-doc.md](docs/design-doc.md) |
| Step-by-step build plan | [docs/build-steps.md](docs/build-steps.md) |
| Scripts | [src/](src/), written in VS Code and synced into Studio with Rojo |

## Status

Step 0 (setup). The place is still an empty Baseplate: no scripts or models yet.

## Project layout

```text
docs/            design doc and build steps
src/server/      → ServerScriptService.Server   (server systems: combat, matches, lobby, saving)
src/client/      → StarterPlayer.StarterPlayerScripts.Client   (input, camera, UI)
src/shared/      → ReplicatedStorage.Shared     (config, shared types, RemoteEvents setup)
default.project.json   Rojo mapping from src/ to the Roblox place
rokit.toml             pinned tool versions (Rojo, Selene, StyLua)
selene.toml, stylua.toml   lint and format rules
```

## Working on the game

Code is written in **VS Code** as files in `src/`, kept in git, and synced into Studio with **Rojo**. Studio is used to build the map, run playtests and publish.

### One-time setup (each teammate)

1. Ask YUP for Edit access to MMA Dev (you must be Roblox friends with YUP).
2. Install Rokit (the toolchain manager): `curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash`, then restart your terminal.
3. Clone this repo and run `rokit install` inside it. That installs the exact Rojo, Selene and StyLua versions in `rokit.toml`.
4. Install the Rojo plugin into Studio: `rojo plugin install`.
5. Open the folder in VS Code and accept the recommended extensions (Luau LSP, Rojo, StyLua, Selene).

### Day to day

1. `git pull` to get everyone's latest code.
2. `rojo serve` in the repo folder (or "Rojo: Open menu" in VS Code).
3. In Studio, open MMA Dev, click the **Rojo** plugin, then **Connect**. Files in `src/` now sync into the place live.
4. Edit scripts in VS Code only, never in Studio. Studio edits to synced scripts get overwritten by Rojo.
5. When it works: `stylua src && selene src`, then commit on a branch and open a pull request.

### Team Create rule

Only Rojo-managed scripts live in `ServerScriptService.Server`, `ReplicatedStorage.Shared` and `StarterPlayer.StarterPlayerScripts.Client`. Only connect Rojo when your branch is up to date with `main`; otherwise you'll sync older code over a teammate's in the shared place. Maps, models and UI built in Studio stay in Studio.

## Contributing

- Work on a branch, open a pull request, and get one teammate to look before merging into `main`.
- Keep one ModuleScript per system so two people rarely edit the same script.
- The server decides every hit, reward and purchase; never trust values sent by a client.
