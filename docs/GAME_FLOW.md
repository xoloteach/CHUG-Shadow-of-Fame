# Game Flow

## Boot

`Main.tscn` starts the game. The three autoloads initialize in this order conceptually:

- `GameData` loads authored runtime JSON.
- `SaveStore` loads campaign progress.
- `GameSession` exposes the current part and input actions.

## Campaign flow

```text
MAIN MENU
   |
   v
LOAD CURRENT PART
   |
   v
STORY EVENT -----------------------+
   |                               |
   | text                          | fight
   v                               v
CONTINUE                       FIGHT ARENA
   |                               |
   +-------------------------------+
   |
   | end
   v
COMPLETE PART
   |
   v
SAVE NEXT PART
   |
   v
MAIN MENU
```

`story.json` is authoritative for encounter order. `campaign.json` supplies part identity. `combat.json` supplies tuning.

## Fight results

Every fight event declares `required_result`:

- `win`: the player must win the encounter to continue the story.
- `lose`: defeat is the authored result and advances the story.

Part 12's three Arowh enemy-21 encounters are explicitly `lose` events. This removes the old hidden special case where Arowh could not die while the campaign controller still expected a victory.

## Quick Fight

Quick Fight uses the first encounter in the current part and never changes campaign progress.
