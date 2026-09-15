# Start Here

This file is the fast entry point for a developer or coding agent opening CHUG for the first time.

## What this repository is

**CHUG: Shadow of Fame** is a Godot 4 rebuild of the original browser prototype. This repository is intentionally lean. It contains only the systems used by the current playable loop.

The current loop is:

```text
Menu
  -> Current campaign part
  -> Story event
  -> Fight when requested
  -> Resolve required result
  -> Continue story
  -> End part
  -> Save progress
  -> Unlock next part
```

## Current content snapshot

The validator currently expects:

- 50 campaign parts;
- 1,293 normalized story events;
- 201 fight events;
- 21 enemy combat definitions;
- 3 rage tiers;
- 3 scripted-loss Arowh encounters in Part 12;
- only Worlds I-III because those are the authored worlds containing Parts 1-50.

## Runtime files that matter

```text
project.godot
autoload/
  game_data.gd
  save_store.gd
  game_session.gd

data/
  campaign.json
  story.json
  combat.json

scenes/
  Main.tscn
  combat/FightArena.tscn
  combat/Fighter.tscn

scripts/
  core/main.gd
  campaign/story_sequence.gd
  ui/story_panel.gd
  combat/fight_arena.gd
  combat/fighter.gd
  combat/player_input.gd
  combat/enemy_brain.gd
```

Everything else is documentation, art source/output space, or tooling.

## First five things to do

From the repository root:

```bash
python3 tools/validate_project.py
```

If Godot is installed:

```bash
godot --version
godot --headless --path . --import
godot --headless --path . --quit-after 5
```

Then read the first open work item in `docs/BUILD_PLAN.md`.

## Missing GLB files are not a startup failure

These model slots are optional during development:

```text
assets/models/characters/chug.glb
assets/models/characters/enemy.glb
```

If they are absent, `Fighter.tscn` uses a debug mesh. Do not block combat-code work on final art.

## Controls

Desktop:

- `A` / `D` or Left / Right: move
- `W`, Space, or Up: jump
- `J`: light attack
- `K`: heavy attack
- `R`: rage

Touch buttons trigger the same Godot input actions.

## Where to change things

| Goal | Start here |
|---|---|
| Change campaign order/title metadata | `data/campaign.json` |
| Edit story event order/text/fights | `data/story.json` |
| Change combat tuning | `data/combat.json` |
| Change attack execution/damage | `scripts/combat/fighter.gd` |
| Change enemy decisions | `scripts/combat/enemy_brain.gd` |
| Change round/match rules/HUD | `scripts/combat/fight_arena.gd` |
| Change story flow | `scripts/core/main.gd` + `scripts/campaign/story_sequence.gd` |
| Change save persistence | `autoload/save_store.gd` |
| Change campaign progression | `autoload/game_session.gd` |
| Add final character models | `assets/blender/` -> `assets/models/characters/` |

## What not to do

Do not begin by adding more managers, databases, currencies, codex screens, equipment systems, progression trees, or future-world placeholders.

Do not convert the project back into one giant script.

Do not rewrite the story while performing a code-cleanup task.

Read `AGENTS.md` before making changes.
