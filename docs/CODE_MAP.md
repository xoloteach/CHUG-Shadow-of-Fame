# Code Map

## Autoloads

| File | Owns | Does not own |
|---|---|---|
| `autoload/game_data.gd` | JSON loading, indexes, explicit data queries | saves, combat state, UI |
| `autoload/save_store.gd` | disk read/write for campaign progress | progression rules, content |
| `autoload/game_session.gd` | current part, part completion, input action setup | JSON parsing, fight logic |

## Campaign / UI

| File | Responsibility |
|---|---|
| `scripts/core/main.gd` | coordinates menu -> story -> fight -> story -> completion |
| `scripts/campaign/story_sequence.gd` | cursor over one part's event array |
| `scripts/ui/story_panel.gd` | presents one event and emits continue/fight/complete |

## Combat

| File | Responsibility |
|---|---|
| `scripts/combat/fighter.gd` | movement physics, health, stamina, rage, attack timing, damage |
| `scripts/combat/player_input.gd` | converts local input into fighter commands |
| `scripts/combat/enemy_brain.gd` | chooses enemy movement and attacks |
| `scripts/combat/fight_arena.gd` | spawns fighters, tracks rounds, updates HUD, emits match result |

## Dependency direction

```text
UI / Main
   -> GameSession
   -> GameData
   -> FightArena
        -> Fighter
        -> PlayerInputController
        -> EnemyBrain
        -> GameData

GameSession -> SaveStore
GameSession -> GameData
SaveStore   -> disk only
GameData    -> JSON only
```

The dependency direction is intentional. `Fighter` never edits campaign progress. `SaveStore` never decides unlocks. `EnemyBrain` never applies damage directly.
