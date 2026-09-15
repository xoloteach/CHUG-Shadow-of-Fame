# Acceptance Tests

Use this checklist after meaningful gameplay changes.

## A. Static content validation

Run:

```bash
python3 tools/validate_project.py
```

Expected result starts with:

```text
VALIDATION PASSED
```

The validator must still confirm the campaign/event/enemy/rage counts and no banned stale runtime systems.

## B. Engine startup

With Godot 4.7.2 available:

```bash
godot --headless --path . --import
godot --headless --path . --quit-after 5
```

Pass criteria:

- no GDScript parser error;
- no missing mandatory `.tscn`, `.gd`, or JSON resource;
- Main scene can instantiate;
- missing optional `chug.glb`/`enemy.glb` is handled by debug visuals rather than a crash.

## C. Fresh-save campaign test

1. Remove/reset the CHUG save through the game UI.
2. Confirm menu shows Part 1.
3. Start campaign.
4. Confirm story events advance in authored order.
5. Reach a fight.
6. Lose a normal `required_result: win` encounter.
7. Confirm the part is not completed.
8. Replay and win.
9. Continue to the `end` event.
10. Complete the part.
11. Confirm menu shows the next part.

## D. Scripted-loss regression test

Part 12 contains three enemy-21 Arowh fights whose required result is `lose`.

For each relevant encounter:

- losing must allow story continuation;
- winning must not be treated as the authored defeat;
- there must be no hidden enemy immortality special-case needed to make the story work.

## E. Quick Fight isolation

1. Record current campaign part and completed-parts list.
2. Start Quick Fight.
3. Finish the fight with either result.
4. Return to menu.
5. Confirm campaign progress is byte-for-byte semantically unchanged.

## F. Round-flow test

For a normal best-of-three fight:

- Round 1 spawns one player and one enemy;
- HUD starts at full values;
- defeat increments only one side's score once;
- fighters respawn for the next round;
- match ends when one side reaches `rounds_to_win`;
- `fight_finished` emits once;
- no fighter from an old round remains active.

## G. Input test

Desktop:

- left/right movement works;
- jump works only when legal;
- light/heavy consume appropriate stamina;
- insufficient stamina blocks the attack;
- rage cannot activate early;
- rage activates when full;
- leaving an encounter releases synthetic input actions.

Touch:

- press and release map to the same Godot actions;
- holding movement behaves continuously;
- releasing a button stops its action;
- changing scenes does not leave an action stuck pressed.

## H. Save test

Save must contain only:

```json
{
  "current_part": 1,
  "completed_parts": [],
  "campaign_complete": false
}
```

Values vary with progress, but no unrelated keys should persist.

Test:

1. progress a part;
2. restart the game;
3. confirm progress reloads;
4. reset progress;
5. restart again;
6. confirm clean Part 1 state.

## I. Campaign completion test

At Part 50:

- complete the final `end` event;
- Part 50 appears in completed parts;
- `campaign_complete` becomes true;
- menu reports campaign completion;
- Continue Campaign is disabled;
- no nonexistent Part 51 is created or requested.

## J. Change-specific test

Every pull request/task should add one sentence to its work notes describing the exact behavior manually or automatically checked. Do not rely only on "project starts" when changing combat logic.
