# Repository Contract

This document defines what belongs in this repository and what should stay outside it.

## Runtime source

Commit:

- `.gd` gameplay/UI/autoload scripts;
- `.tscn` scenes;
- `project.godot`;
- authored runtime JSON actually consumed by the game;
- small configuration needed to build/run the current game.

## Art source

Commit Blender source when it is an intentional project source asset and repository size remains practical.

Keep editable sources in:

```text
assets/blender/
```

Commit exported runtime GLBs in:

```text
assets/models/
```

only when they are real assets used by the game.

## Documentation

Keep documentation that answers one of these questions:

- how does the current game work?
- who owns this behavior?
- how do I build/test it?
- what is intentionally removed?
- what is the next agreed implementation task?

Delete docs that only describe abandoned architecture or speculative features.

## Generated files

Do not commit normal Godot import/cache/editor state or temporary build outputs.
Do not commit Cloud Shell caches or downloaded engine binaries.

## Data rule

A runtime data field must have a current reader.
A runtime data table must have a current gameplay/UI consumer.

If data is kept only because an old prototype had it, it does not belong in the lean runtime.

## Dependency rule

Core dependency direction remains:

```text
Main/UI -> GameSession/GameData/FightArena
GameSession -> SaveStore + GameData
FightArena -> Fighter + controllers
Fighter/controllers -> GameData
SaveStore -> disk
GameData -> JSON
```

Avoid circular global dependencies.

## Naming rule

Prefer concrete names describing ownership:

Good:

- `SaveStore`
- `GameData`
- `FightArena`
- `EnemyBrain`

Avoid vague containers such as:

- `ManagerManager`
- `GlobalUtils`
- `EverythingSystem`
- `FeatureRegistry`

unless a real cross-cutting need proves they are necessary.
