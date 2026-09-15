# Cleanup Report

## Before

The previous package had:

- 56 files.
- 1,087 lines of GDScript.
- 14,015 lines of JSON including legacy duplication.
- 9 split content databases plus a full legacy copy.
- Empty/planned scene and script folders.
- Generic data access that exposed every imported system whether implemented or not.
- Save fields for currencies, equipment, upgrades and training that the playable Godot loop did not use.
- Runtime codex references and counters.
- Placeholder/future world content.
- Combat AI, player input, physics and damage combined in one fighter controller.
- A Part 12 campaign flow bug: authored Arowh losses were represented as fights the campaign expected the player to win.

## After

The lean package has:

- 29 files before this report/save-schema documentation, with no empty feature folders.
- 869 lines of GDScript at the cleanup checkpoint.
- 6,611 lines of runtime JSON at the cleanup checkpoint.
- Exactly 3 runtime data files: campaign, story and combat.
- Explicit typed story events.
- Separate input, AI, fighter and match ownership.
- Minimal save state.
- No runtime references to codex, training trees, squad support, camp missions, equipment, gems or legacy passthrough data.
- Only Worlds I-III because those are the worlds containing the 50 authored parts.
- Three explicit scripted-loss events for Arowh in Part 12.

## Story-content policy

The existing story prose was retained rather than automatically rewritten or deleted. This cleanup targets architecture, dead systems, unused metadata and code/data bloat. Narrative editing should be a separate deliberate pass so real story material is not destroyed by an automated "AI slop" guess.
