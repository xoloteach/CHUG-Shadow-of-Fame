# Blender -> Godot Art Pipeline

This pipeline exists to add real art without coupling combat logic to a specific Blender file layout.

## Folder contract

```text
assets/
  blender/
    # editable .blend sources and source-side texture folders
  models/
    characters/
      chug.glb
      enemy.glb
    # future real environment GLBs may get their own explicit folders when used
```

Do not put `.blend` files in the runtime model folder.
Do not treat exported GLBs as the editable master source.

## Current runtime model slots

`Fighter` looks for:

```text
res://assets/models/characters/chug.glb
res://assets/models/characters/enemy.glb
```

If absent, debug meshes are used.

The first art milestone should use these exact slots. Do not add a character-selection asset database before the game needs one.

## Blender scene requirements

For the first production-ready fighter rig:

- metric scale should be consistent;
- root should be at a predictable floor origin;
- forward direction should be tested against Godot's fighter facing behavior;
- one armature should own the deforming skeleton;
- mesh transforms should be applied before final export when appropriate;
- unnecessary cameras/lights/helpers should not be exported;
- bone names should remain stable after animation integration begins.

## Initial animation contract

The gameplay layer should be able to request semantic actions equivalent to:

- idle;
- run;
- jump;
- light attack;
- heavy attack;
- hit reaction;
- rage activation/loop as needed;
- defeat.

Exact Blender action names should be documented once the first rig is connected. Until then, code must fail gracefully if an animation is missing.

## Export format

Use GLB/glTF 2.0 for Godot runtime imports.

Recommended export approach:

- export selected game objects only;
- include armature + skinned meshes;
- include only required animation actions;
- avoid exporting Blender-only helpers;
- verify materials/textures after Godot import;
- keep physics collision in Godot unless a specific environment asset benefits from imported collision data.

## Integration checklist

For each fighter GLB:

1. copy/export to the expected runtime path;
2. run Godot import;
3. instantiate a fight;
4. verify world scale;
5. verify feet align with the arena floor;
6. verify left/right facing;
7. verify collision capsule alignment;
8. verify no mesh clips below floor at rest;
9. verify animation playback if connected;
10. verify debug fallback still works when the GLB is removed.

## Art should not own game rules

Do not encode campaign progression, damage amount, stamina cost, or enemy AI inside Blender data.

Animation timing may inform active frames, but authoritative combat rules belong to Godot/runtime data.

## Cloud Shell note

Cloud Shell is useful for repository validation, headless Godot imports, scripted exports, and optionally Blender command-line checks.

It is not a good replacement for an interactive local Blender workstation. Do detailed modeling/rigging/animation in Blender on a machine with a proper GUI/GPU, commit/export the resulting assets, then use Cloud Shell for automated verification if desired.
