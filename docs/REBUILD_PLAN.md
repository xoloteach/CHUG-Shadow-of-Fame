# CHUG: Rebuild & Redesign Master Plan (Clean & Fluid Architecture)

## Vision
Rebuild **CHUG: Shadow of Fame** from the ground up using the clean data layer and 50-part campaign structure as the foundation, while transforming the gameplay into a **tight, fluid, responsive 2.5D fighting experience**.

---

## 1. Architecture Pillars

### Core Philosophy
- **Modular, Decoupled Systems:** Clean separation between Core Session, Campaign Flow, Combat Mechanics, and Presentation.
- **State Machine Driven:** Deterministic state machines for fighters (neutral, startup, active, recovery, hitstun, blockstun, knockdown, wakeup).
- **Exact Box Collision:** Frame-accurate Hitbox / Hurtbox / Pushbox architecture instead of simple distance checks.
- **Buffer & Input Windows:** Lenient input buffering (4–6 frames) to make combos, links, and special/rage cancels feel fluid.
- **Visual & Audio Feedback:** Camera shake, hit sparks, hit-stop (freeze frames), dynamic health bars, and fluid UI transitions.

---

## 2. Phased Rebuild Roadmap

### Phase 1: Engine Foundation & Workspace Verification
- [x] Install **Godot 4.7.2 stable** CLI in Cloud Shell.
- [x] Run headless import and verify project initialization with zero errors.
- [ ] Establish automated headless smoke-test runner (`tools/run_tests.gd`).
- [ ] Set up clean project directory structure and conventions (`res://src/`).

### Phase 2: Core Data & Session Management
- **`GameData` Service:** Robust typed data loader for `campaign.json`, `story.json`, and `combat.json` with strict schema validation.
- **`SaveManager`:** Lightweight JSON persistence for unlocked parts, completed encounters, and settings.
- **`GameFlowController`:** Clean scene transition coordinator handling `MainMenu -> StoryViewer -> CombatArena -> Result/Progress`.

### Phase 3: Fluid Combat Engine (From Scratch)
1. **Fighter Action State Machine:**
   - States: `Idle`, `Move`, `JumpStart`, `JumpAir`, `JumpLand`, `LightAttack`, `HeavyAttack`, `RageActive`, `HitStun`, `Knockdown`, `Wakeup`, `Defeated`.
   - Action locks and cancel windows (e.g., Light cancels into Heavy or Rage on hit).
2. **Hitbox / Hurtbox / Pushbox System (`Area3D`):**
   - Separate collision layers for attack hitboxes, body hurtboxes, and physical fighter separation pushboxes.
   - Attack windows: Startup frames -> Active frames (hitbox enabled) -> Recovery frames.
   - Single-hit registration per attack swing (no multi-hit jitter).
3. **Impact Feedback:**
   - Configurable hit-stop (micro freeze frames on hit: 4–8 frames).
   - Dynamic directional knockback and hit flash.
   - Combat camera framing with soft tracking, zoom on critical hits, and clamp boundaries.
4. **Input Buffer & Controls:**
   - 6-frame input buffer queue for smooth command execution.
   - Desktop and responsive mobile touch overlay sharing unified action inputs.

### Phase 4: Enemy AI (Fluid & Readable)
- **State-Based Behavior Tree / Utility AI:**
  - Range management: zoning, retreating, rushing in, reacting to player attacks.
  - Variable reaction time and whiff punishment based on enemy aggression stat.
  - Scripted loss encounters (e.g. Part 12 Arowh) handled cleanly via match rules.

### Phase 5: Polished UI & Story Presentation
- **Dynamic Story Reader:**
  - Typewriter text effect with skip support.
  - Character portrait / color cues matching narrative tone.
  - Clean transition directly into fight matches.
- **Sleek Fighting HUD:**
  - Segmented health bar with delayed damage trail (chip damage animation).
  - Stamina recovery indicator.
  - Rage meter with visual pulse at 100% capacity.
  - Round indicators and fight announcer banners (`FIGHT!`, `K.O.!`, `VICTORY!`).

### Phase 6: Art & Animation Integration Pipeline
- Modular model slots (`res://assets/models/characters/`):
  - `chug.glb` (Player)
  - `enemy_*.glb` or shared rigged enemy variants.
- Fallback debug visualizer that accurately shows hurtbox/hitbox bounds for rapid mechanical tuning.
- Semantic animation hook dispatcher (`idle`, `walk`, `jump`, `attack_light`, `attack_heavy`, `hit`, `down`, `rage`).

### Phase 7: Verification & Acceptance
- Run headless automated validation over all 50 campaign parts and 201 fights.
- Verify zero regression in scripted losses (Part 12).
- Verify clean save/load cycles and isolation of Quick Fight from campaign progress.
