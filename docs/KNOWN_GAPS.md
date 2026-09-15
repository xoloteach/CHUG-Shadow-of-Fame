# Known Gaps

This file lists real gaps in the current playable foundation. It deliberately excludes removed/speculative features.

## Engine verification

The project needs a clean Godot 4.7.2 import/parser/runtime smoke pass in an environment with the engine installed.

## Combat

Current combat is functional but early:

- attacks use range/distance checks rather than authored hitbox/hurtbox overlap;
- no production animation integration is present;
- round-start/end input locking can be made more explicit;
- enemy behavior is intentionally basic;
- combat feel has not been tuned against final animations/models;
- arena presentation is debug-level.

## Art

Final production assets are not present:

- Chug model/rig;
- enemy model/rig;
- production combat animation set;
- authored arena environment;
- production materials/textures.

Debug meshes exist so code remains testable.

## Audio

No production audio implementation should be assumed complete until actual assets and playback ownership are integrated/tested.

## Platform build configuration

No baseline `export_presets.cfg` is currently part of the lean project.
Therefore Cloud Shell can validate/import/run headlessly, but platform packaging is not yet a defined repository contract.

## Testing

The Python validator checks data/resource structure, not full gameplay behavior.
Automated Godot smoke tests are a useful next step after the first clean engine import.

## Campaign QA

The campaign data is structurally validated, but a full playthrough/pacing/presentation QA pass remains separate from structural correctness.

## Not gaps

The following are not considered missing unless explicitly requested:

- codex;
- XP/gems/currencies;
- equipment/armor;
- training trees;
- squad/camp systems;
- Worlds IV-VII;
- generic future-feature frameworks.
