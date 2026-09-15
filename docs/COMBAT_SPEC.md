# Combat Specification

This document describes the combat system that actually exists now. It is a contract for further implementation, not a wishlist.

## Combat format

Combat is a side-view 3D arena with movement constrained primarily along the X axis.

Each encounter specifies:

- `enemy_id` from 1 to 21;
- `rounds_to_win` from 1 to 3;
- campaign-derived rage tier.

`FightArena` runs rounds until the player or enemy reaches `rounds_to_win`.

## Ownership

### `FightArena`

Owns:

- spawning both fighters;
- connecting fighter signals;
- player/enemy round wins;
- round number;
- HUD values;
- match completion;
- touch-button bindings.

It does not own fighter damage formulas or campaign progression.

### `Fighter`

Owns:

- movement velocity;
- jump execution;
- action state (`neutral`, `attacking`, `hit-stunned`, `defeated`);
- command locking during round transitions;
- facing;
- health;
- stamina;
- rage meter/active rage;
- attack timing;
- hit application;
- knockback;
- hit stun;
- defeat emission.

### `PlayerInputController`

Reads Godot input actions and requests commands from the player fighter.

### `EnemyBrain`

Chooses enemy movement and attacks. It must not directly alter health, position, or campaign state.

## Current attack model

Two attacks exist:

- `light`
- `heavy`

Their authored values live in `data/combat.json`:

- stamina cost;
- total duration;
- hit timing ratio;
- range;
- damage multiplier;
- knockback X/Y;
- hit stun.

The current hit test is distance-based. This is functional but is considered an early combat implementation. The next combat-architecture upgrade should replace it with explicit hitbox/hurtbox overlap without changing campaign code.

Fighters accept commands only while neutral and unlocked. Attacking, hit stun, defeat, and arena-controlled round transitions block new commands. The arena releases synthetic touch actions before each round and when a round ends, so held input cannot leak across rounds.

## Damage

Conceptually:

```text
raw attack damage = fighter base damage * attack multiplier * rage multiplier
received damage = max(1, raw attack damage - defender defense)
```

When the defender has active rage, `damage_taken_multiplier` is applied according to the current rage tier.

## Stamina

Player attacks consume stamina.
Stamina regenerates over time using `resources.stamina_regen_per_second`.
An attack request should fail when stamina is below that attack's cost.

Enemy stamina is currently not a player-visible resource and should not receive speculative UI unless enemy stamina becomes an implemented rule.

## Rage

Player rage increases from:

- landing light attacks;
- landing heavy attacks;
- taking damage.

Rage can activate when full and drains while active.

Rage tiers are campaign-gated in `data/combat.json`.
Current authored unlock points are part-driven and must be read through `GameData`; do not hard-code tier progression into UI or fighters.

## Defeat

A fighter emits `defeated` once when health reaches its minimum defeat threshold.
`FightArena` owns converting a fighter defeat into a round result.

The arena emits only the final match result:

```gdscript
fight_finished(player_won: bool)
```

Campaign code then compares that result with the story event's required result.

## Scripted-loss encounters

A scripted-loss fight is not a fake cinematic flag. It is a normal match whose story event says:

```json
"required_result": "lose"
```

If the player wins such a fight, the story must not advance as though the authored defeat occurred.

## Next technical combat milestone

The next combat-layer work should happen in this order:

1. hitbox/hurtbox nodes instead of pure distance checks;
2. animation hooks driven by fighter state;
3. attack recovery/cancel rules;
4. enemy behavior improvements using the same Fighter command API;
5. only then expand move variety if requested.

Do not add combo databases or skill trees before the basic combat state machine is reliable.
