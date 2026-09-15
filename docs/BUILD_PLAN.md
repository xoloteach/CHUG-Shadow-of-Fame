# Build Plan

This is the ordered implementation queue. It exists so an agent can continue the rebuild without inventing features or spending a session rediscovering priorities.

The owner can override this order at any time.

## Phase 0 — Make the repository mechanically trustworthy

**Priority: P0**

### 0.1 Godot import/parser pass

Goal: prove the repository opens cleanly in the target engine.

Tasks:

- install/use Godot 4.7.2 stable;
- run the Python validator;
- run Godot headless import;
- run the main scene headlessly for a few frames;
- fix only real parser/resource/runtime startup errors;
- do not add gameplay features during this pass.

Done when:

```bash
python3 tools/validate_project.py
godot --headless --path . --import
godot --headless --path . --quit-after 5
```

all complete without project-caused errors.

### 0.2 Establish lightweight automated smoke checks

Goal: catch broken project startup before future work is merged.

Prefer small Godot test scripts or headless scene checks over introducing a large test framework.

Minimum targets:

- GameData loads 50 parts;
- save defaults are valid;
- Main scene instantiates;
- FightArena instantiates;
- a fighter can be configured with valid player/enemy data.

Do not introduce a framework unless the checks cannot remain simple.

---

## Phase 1 — Make combat architecture solid

**Priority: P0/P1**

### 1.1 Explicit fighter action state — complete

Implemented: `Fighter` uses the real current states `neutral`, `attacking`, `hit-stunned`, and `defeated`. Commands are accepted only while neutral.

### 1.2 Replace distance hit detection with hitbox/hurtbox overlap

Current hit logic uses horizontal distance and attack range.

Replace this with explicit scene nodes, for example:

```text
Fighter
  Hurtbox (Area3D)
  AttackOrigin
    LightHitbox (Area3D)
    HeavyHitbox (Area3D)
```

Requirements:

- hitboxes are active only during the attack's active window;
- one attack cannot hit the same opponent repeatedly in one swing;
- damage continues to be applied by `Fighter`, not `EnemyBrain`;
- attack data remains in `combat.json` where it is tuning rather than behavior.

### 1.3 Round input lock — complete

Implemented: fighters are command-locked before `FIGHT`, after a defeat, and on match exit. Synthetic touch actions are released at each boundary.

### 1.4 Animation interface

Add animation hooks without hard-depending on final models.

The gameplay fighter should be able to request semantic animation names such as:

- idle;
- run;
- jump;
- light_attack;
- heavy_attack;
- hit;
- rage;
- defeat.

If a loaded model has no matching animation, combat must still function with the debug visual.

Do not embed combat damage events only inside animation assets until fallback behavior is tested.

---

## Phase 2 — Improve enemy behavior without adding AI clutter

**Priority: P1**

Enemy behavior should stay inside `EnemyBrain` and use the same Fighter request API as player input.

### 2.1 Better spacing

Add intentional ranges:

- approach when too far;
- stop or reposition in attack range;
- avoid constant overlap/jitter.

### 2.2 Attack choice

Use existing light/heavy attack rules and enemy aggression values.
Do not create unused personality databases.

### 2.3 Reaction timing

Enemy decisions should have readable delays and should not react every physics frame like a perfect bot.

### 2.4 Difficulty tuning

Only add new enemy tuning fields when runtime code consumes them and at least one enemy needs a meaningful difference.

---

## Phase 3 — Presentation that supports the existing game

**Priority: P1**

### 3.1 HUD polish

Improve current HUD readability while keeping the same real resources:

- health;
- stamina;
- rage;
- round count;
- fight result.

Do not add fake currencies or meters.

### 3.2 Story presentation

Improve typography, transitions, and pacing without rewriting story content by default.

### 3.3 Arena presentation

Replace debug arena geometry with authored environment assets while preserving collision and camera behavior.

### 3.4 Audio integration

Add audio only when actual sound assets exist. Keep playback ownership explicit:

- attacks/hits -> combat layer;
- menu/story UI -> UI layer;
- music -> one clear music owner.

Do not build an empty audio architecture before assets exist.

---

## Phase 4 — Blender character pipeline

**Priority: P1/P2**

Use `docs/ART_PIPELINE.md`.

Initial deliverables:

1. Chug base model;
2. enemy base model or a deliberately shared enemy rig;
3. game-ready skeleton;
4. animation set needed by current combat;
5. exported GLBs in the existing model slots;
6. verify orientation/scale/collision alignment in Godot.

Do not create 21 final enemy models before the base rig/export/animation contract is proven on one enemy.

---

## Phase 5 — Campaign-wide reliability pass

**Priority: P1 after combat is stable**

Automate or manually verify:

- all 50 parts load;
- all 201 fight events reference valid enemies;
- normal win fights advance only after wins;
- the three Part 12 scripted losses advance only after losses;
- Part 50 reaches campaign-complete state;
- reset returns to Part 1;
- Quick Fight never changes progression.

This phase is reliability work, not an excuse to add more systems.

---

## Explicitly not on the build queue

Unless the owner requests them, the following are not backlog items:

- codex;
- currencies;
- XP;
- equipment/armor;
- training trees;
- squad-support database;
- camp missions;
- future Worlds IV-VII;
- generic dialogue scripting engine;
- online multiplayer;
- procedural lore generation.

Their absence is intentional, not an unfinished checkbox.
