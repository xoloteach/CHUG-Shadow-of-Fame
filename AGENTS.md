# CHUG Agent Instructions

This repository is the current source of truth for **CHUG: Shadow of Fame**.

The repository has deliberately been reduced to the smallest runtime that represents the game that currently exists: campaign, story, combat, rage, input, UI, and save progress. Older browser code, speculative systems, and unused databases are not authoritative.

## Mandatory read order

Before changing code, read these files in order:

1. `START_HERE.md`
2. `docs/IMPLEMENTATION_STATUS.md`
3. `docs/CODE_MAP.md`
4. `docs/GAME_FLOW.md`
5. `docs/DATA_SCHEMA.md`
6. `docs/COMBAT_SPEC.md`
7. `docs/BUILD_PLAN.md`
8. `docs/ACCEPTANCE_TESTS.md`
9. `docs/REMOVED_SYSTEMS.md`
10. `docs/CLOUD_SHELL_SETUP.md`

If a task concerns Blender/model work, also read `docs/ART_PIPELINE.md`.
If a task concerns campaign content, also read `docs/CAMPAIGN_SPEC.md`.

## Source-of-truth priority

When files disagree, use this priority:

1. Working runtime code and scenes.
2. `data/campaign.json`, `data/story.json`, `data/combat.json`.
3. `AGENTS.md` and `START_HERE.md`.
4. Files in `docs/`.
5. Old CHUG/browser projects only when explicitly provided as a reference for a missing behavior.

Do not copy architecture from an older build merely because it contains more code.

## Hard rules

### 1. No speculative systems

Do not add a system because it might be useful later. A new runtime system needs:

- a current player-facing purpose;
- a current scene or gameplay integration point;
- runtime code that consumes it;
- a test or acceptance check.

If those four items cannot be named, do not add it.

### 2. Do not reintroduce removed clutter

Do not re-add runtime codex, gems, XP, equipment, armor, training trees, squad support, camp missions, combo unlock databases, empty future worlds, generic legacy-data passthroughs, or speculative save migration frameworks unless the owner explicitly asks for that feature again.

See `docs/REMOVED_SYSTEMS.md`.

### 3. One responsibility per script

Current ownership boundaries are intentional:

- `GameData`: authored JSON loading/querying only.
- `SaveStore`: persistence only.
- `GameSession`: campaign progression and global input bootstrap.
- `Main`: menu/story/fight orchestration only.
- `StorySequence`: event cursor only.
- `StoryPanel`: story presentation only.
- `FightArena`: encounter/round/HUD ownership.
- `Fighter`: character physics/resources/damage/attack execution.
- `PlayerInputController`: player commands only.
- `EnemyBrain`: enemy decisions only.

Do not turn one of these into a generic god-object.

### 4. Data is for authored values; code is for behavior

Keep tuning and authored content in the three runtime JSON files when appropriate.
Do not put executable behavior, class names, arbitrary script paths, or future feature flags in JSON.
Do not create JSON fields that no current runtime code reads.

### 5. Preserve campaign semantics

The campaign has 50 ordered parts.
Story events are explicitly `text`, `fight`, or `end`.
A fight declares `required_result` as `win` or `lose`.
The three Arowh encounters in Part 12 are authored scripted losses and must advance only when the player loses those encounters.
Quick Fight must never change campaign progress.

### 6. Story prose is protected by default

Do not rewrite or delete story prose unless the current task explicitly requests narrative editing. Architectural cleanup must not silently become story rewriting.

### 7. Keep changes small and verifiable

For each change:

1. state the behavior being changed;
2. identify the smallest owner file;
3. implement it without unrelated refactors;
4. run static validation;
5. run Godot headless import/parser checks when Godot is available;
6. update documentation only if architecture, data schema, controls, or behavior changed.

### 8. No fake completion

Do not describe an unimplemented feature as complete.
Do not add placeholder folders or placeholder code to make the project look larger.
Debug meshes are allowed only as the current fallback for missing character GLBs because they keep combat testable.

### 9. Godot target

Target Godot 4.x GDScript, with **Godot 4.7.2 stable** as the current CI/Cloud Shell reference version.
Keep the Compatibility renderer unless a tested gameplay requirement requires another renderer.

### 10. Blender asset rule

Real Blender sources belong in `assets/blender/`.
Game-ready GLB exports belong in `assets/models/`.
Do not generate fake final art through procedural placeholder scripts.
Do not make core combat depend on a model being present; the debug visual fallback must remain usable until final models exist.

## Required checks before declaring a coding task done

Run:

```bash
python3 tools/validate_project.py
```

When Godot is installed:

```bash
godot --headless --path . --import
godot --headless --path . --quit-after 5
```

A task is not done if either command reports a new parser/resource/runtime error caused by the change.

## Definition of done

A gameplay change is complete only when all of the following are true:

- the intended behavior exists in a real gameplay path;
- no unused runtime field/file was introduced;
- static validation passes;
- Godot parses/imports the project when the engine is available;
- the relevant acceptance checks in `docs/ACCEPTANCE_TESTS.md` pass;
- no removed system was accidentally restored;
- documentation reflects any changed contract.

## What to build next

Do not invent a new roadmap. Use `docs/BUILD_PLAN.md` in priority order unless the owner gives a different task.

The immediate priority is to turn the current functional vertical slice into a robust fighting-game foundation: engine validation, real hit/hurt detection, animation hooks, combat state correctness, better match flow, then real Blender character/environment assets and presentation.
