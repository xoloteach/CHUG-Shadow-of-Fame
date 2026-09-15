# Terra 5.6 Handoff

This repository is prepared so a coding agent can begin from documented contracts instead of reverse-engineering the old browser prototype.

## Read this exact sequence

1. `AGENTS.md`
2. `START_HERE.md`
3. `docs/IMPLEMENTATION_STATUS.md`
4. `docs/CODE_MAP.md`
5. `docs/GAME_FLOW.md`
6. `docs/DATA_SCHEMA.md`
7. `docs/COMBAT_SPEC.md`
8. `docs/BUILD_PLAN.md`
9. `docs/ACCEPTANCE_TESTS.md`
10. `docs/KNOWN_GAPS.md`
11. `docs/REMOVED_SYSTEMS.md`

If working in Google Cloud Shell, read `docs/CLOUD_SHELL_SETUP.md` before modifying code.
If working on Blender assets, read `docs/ART_PIPELINE.md`.

## First command

```bash
python3 tools/validate_project.py
```

Then, if Godot is installed:

```bash
godot --headless --path . --import
godot --headless --path . --quit-after 5
```

## First implementation priority

Do not create a new feature list.
Take the first unfinished item in `docs/BUILD_PLAN.md` unless the owner explicitly gives another task.

At the time this handoff was written, priority begins with:

1. clean Godot 4.7.2 engine validation;
2. small automated smoke checks;
3. combat action-state correctness;
4. hitbox/hurtbox upgrade;
5. animation hooks;
6. enemy/round-flow improvements;
7. production Blender assets and presentation.

## Non-negotiable cleanup rule

This is the lean rebuild.
Do not restore removed systems from older CHUG versions merely because source data exists somewhere else.

Before adding a new file, manager, data table, or save field, answer:

- Which current gameplay path uses it?
- Which current scene/system owns it?
- How is it tested?

If those answers do not exist, do not add it.

## Important campaign regression

Part 12 contains three Arowh encounters authored as losses. They are represented explicitly by `required_result: "lose"`.
Do not reintroduce enemy-immortality hacks or hard-coded Part 12 exceptions in combat code.

## Reporting work

At the end of a coding session, report:

- exact files changed;
- exact behavior implemented;
- static validator result;
- Godot import/startup result if available;
- tests not performed;
- next smallest recommended task.

Never call a feature finished simply because files were added.
