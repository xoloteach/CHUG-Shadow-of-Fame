# CHUG: Shadow of Fame — Lean Godot Rebuild

This is the stripped rebuild of CHUG. It intentionally contains only systems that are implemented and used by the current playable loop.


## Developer / coding-agent entry point

Start with [`AGENTS.md`](AGENTS.md), then [`START_HERE.md`](START_HERE.md). The build queue is in [`docs/BUILD_PLAN.md`](docs/BUILD_PLAN.md), and Google Cloud Shell setup is in [`docs/CLOUD_SHELL_SETUP.md`](docs/CLOUD_SHELL_SETUP.md).

Do not begin by reconstructing features from the old browser build. The lean repository and its documented contracts are the source of truth.

## Playable loop

1. Start at the current campaign part.
2. Read the part's story events.
3. Enter fights when the story requests them.
4. Win normal encounters or complete authored scripted-loss encounters.
5. Reach the end event.
6. Save completion and unlock the next part.
7. Repeat through Part 50.

There are no fake feature counters, empty feature folders, or runtime data for screens that do not exist.

## Runtime structure

```text
autoload/
  game_data.gd       Typed access to campaign/story/combat data
  save_store.gd      Reads and writes campaign progress only
  game_session.gd    Campaign progression + input bootstrap

data/
  campaign.json      50-part structural metadata
  story.json         Normalized text/fight/end events grouped by part
  combat.json        Player, enemy, attack and rage tuning
scenes/
  Main.tscn
  combat/FightArena.tscn
  combat/Fighter.tscn
scripts/
  campaign/story_sequence.gd
  combat/fighter.gd
  combat/player_input.gd
  combat/enemy_brain.gd
  combat/fight_arena.gd
  core/main.gd
  ui/story_panel.gd
assets/
  blender/           Put real .blend source here
  models/            Exported GLB model slots
docs/
  Detailed architecture and cleanup notes
tools/
  validate_project.py
```

## Controls

- A / D or Left / Right: move
- W / Space / Up: jump
- J: light attack
- K: heavy attack
- R: activate rage when full
- Touch buttons mirror the same actions.

## Blender model slots

The fighter scene automatically looks for:

- `res://assets/models/characters/chug.glb`
- `res://assets/models/characters/enemy.glb`

If those files do not exist, the scene uses a simple debug mesh so combat remains testable. No generated placeholder Blender asset pipeline is included.

## Important scope rule

If a system is not represented in this repository's code map, it is not pretending to exist. Re-add features only when there is a concrete design and an implementation plan.

See `docs/REMOVED_SYSTEMS.md` for what was deliberately deleted.
