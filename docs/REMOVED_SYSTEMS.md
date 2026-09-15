# Deliberately Removed

This file documents deletions so future work does not accidentally reintroduce old clutter.

## Removed from runtime

- Codex records, unlocks, counters and UI references.
- Roster count / biography data that had no character-selection implementation in the Godot rebuild.
- Squad-support tables that were not connected to combat.
- Camp-event and camp-mission databases that had no playable camp system.
- Training trees containing placeholder/future effects.
- Combo-unlock metadata that had no combo implementation.
- Empty future World IV-VII records.
- Gems, XP, equipment, armor and stat-upgrade save fields that had no implemented economy/UI in this rebuild.
- Generic legacy-data passthrough APIs.
- Save migration scaffolding for schemas this clean build does not ship.
- Generated placeholder Blender asset script.
- Empty scene/script folders and `.gitkeep` files.
- Roadmap text that described speculative features as part of the current architecture.

## What was retained

- The 50-part campaign structure.
- The existing story text and encounter ordering.
- Story color cues because the new story panel renders them.
- Player/enemy combat tuning needed by the playable fights.
- Rage as an implemented combat mechanic.
- Campaign progress saving.

## Re-adding a removed feature

A removed feature should return only when it has all three:

1. A concrete player-facing purpose.
2. A scene/UI or gameplay integration point.
3. Runtime code that consumes its data.

Do not add a database or save keys "for later."
