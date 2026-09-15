# Work Session Protocol

Use this at the beginning and end of an automated coding session.

## Start of session

1. Read `AGENTS.md`.
2. Read `START_HERE.md`.
3. Read the relevant architecture/spec file for the task.
4. Run:

```bash
python3 tools/validate_project.py
```

5. If Godot is available, run:

```bash
godot --headless --path . --import
godot --headless --path . --quit-after 5
```

6. Record the baseline result before editing.
7. Identify the smallest owner file for the requested behavior.

## During the session

- Keep one coherent objective per change set.
- Do not "clean up" unrelated code while implementing a feature.
- Do not add unused data fields.
- Do not add a new manager when an existing owner can cleanly own the behavior.
- If architecture must change, update `docs/CODE_MAP.md` in the same change.
- If runtime JSON shape changes, update `docs/DATA_SCHEMA.md` and the validator in the same change.
- If gameplay semantics change, update the relevant spec and acceptance tests.

## End of session

Run:

```bash
python3 tools/validate_project.py
```

Then, when Godot is available:

```bash
godot --headless --path . --import
godot --headless --path . --quit-after 5
```

Before declaring success, state:

- files changed;
- behavior changed;
- checks executed;
- checks passed/failed;
- known limitation, if any;
- next smallest task.

Never claim a visual/manual test was performed if only headless validation was run.
