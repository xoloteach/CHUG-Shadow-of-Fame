#!/usr/bin/env python3
"""Static validation for CHUG's lean runtime content and resource references."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_json(relative: str):
    path = ROOT / relative
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def validate_campaign(errors: list[str]) -> None:
    data = load_json("data/campaign.json")
    parts = data.get("parts", [])
    ids = [part.get("id") for part in parts if isinstance(part, dict)]
    if ids != list(range(1, 51)):
        errors.append("campaign.json must contain ordered part IDs 1..50")
    world_ids = [world.get("id") for world in data.get("worlds", [])]
    if world_ids != [1, 2, 3]:
        errors.append("campaign.json must contain only authored Worlds 1..3")


def validate_story(errors: list[str]) -> None:
    data = load_json("data/story.json")
    parts = data.get("parts", {})
    if sorted(map(int, parts.keys())) != list(range(1, 51)):
        errors.append("story.json must contain Part 1..50")
        return

    allowed_keys = {
        "type", "text", "color", "enemy_id", "required_result", "rounds_to_win"
    }
    allowed_types = {"text", "fight", "end"}
    scripted_losses = 0

    for part_id, events in parts.items():
        if not events:
            errors.append(f"Part {part_id} has no story events")
            continue
        if events[-1].get("type") != "end":
            errors.append(f"Part {part_id} does not end with an end event")

        for index, event in enumerate(events):
            unknown = set(event) - allowed_keys
            if unknown:
                errors.append(f"Part {part_id} event {index} has unused keys: {sorted(unknown)}")
            event_type = event.get("type")
            if event_type not in allowed_types:
                errors.append(f"Part {part_id} event {index} has invalid type {event_type!r}")
            if event_type == "fight":
                enemy_id = int(event.get("enemy_id", 0))
                if not 1 <= enemy_id <= 21:
                    errors.append(f"Part {part_id} event {index} has invalid enemy_id {enemy_id}")
                result = event.get("required_result")
                if result not in {"win", "lose"}:
                    errors.append(f"Part {part_id} event {index} has invalid required_result")
                if result == "lose":
                    scripted_losses += 1

    if scripted_losses != 3:
        errors.append(f"Expected 3 scripted-loss events; found {scripted_losses}")


def validate_combat(errors: list[str]) -> None:
    data = load_json("data/combat.json")
    enemy_ids = sorted(map(int, data.get("enemies", {}).keys()))
    if enemy_ids != list(range(1, 22)):
        errors.append("combat.json must contain enemies 1..21")
    if set(data.get("attacks", {})) != {"light", "heavy"}:
        errors.append("combat.json must define exactly light/heavy attacks")
    if sorted(map(int, data.get("rage_tiers", {}).keys())) != [1, 2, 3]:
        errors.append("combat.json must define rage tiers 1..3")


def validate_resource_paths(errors: list[str]) -> None:
    resource_pattern = re.compile(r'res://[^"\s]+')
    for path in list(ROOT.rglob("*.gd")) + list(ROOT.rglob("*.tscn")) + [ROOT / "project.godot"]:
        text = path.read_text(encoding="utf-8")
        for resource in resource_pattern.findall(text):
            clean = resource.rstrip('"')
            # GLB model slots are optional by design.
            if clean.endswith("chug.glb") or clean.endswith("enemy.glb"):
                continue
            target = ROOT / clean.removeprefix("res://")
            if not target.exists():
                errors.append(f"{path.relative_to(ROOT)} references missing {clean}")


def validate_no_runtime_slop(errors: list[str]) -> None:
    banned = re.compile(
        r"\b(codex|gems|training_nodes|training_paths|legacy_data|combo_unlocks|"
        r"squad_support|camp_missions|save_version|weapon|armor)\b",
        re.IGNORECASE,
    )
    runtime_paths = [ROOT / "autoload", ROOT / "scripts", ROOT / "scenes", ROOT / "data"]
    for base in runtime_paths:
        for path in base.rglob("*"):
            if path.is_file() and path.suffix in {".gd", ".tscn", ".json"}:
                if path.name == "story.json":
                    continue
                text = path.read_text(encoding="utf-8")
                match = banned.search(text)
                if match:
                    errors.append(
                        f"Banned stale runtime term {match.group(0)!r} found in {path.relative_to(ROOT)}"
                    )


def main() -> int:
    errors: list[str] = []
    validate_campaign(errors)
    validate_story(errors)
    validate_combat(errors)
    validate_resource_paths(errors)
    validate_no_runtime_slop(errors)

    if errors:
        print("VALIDATION FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    story = load_json("data/story.json")["parts"]
    event_count = sum(len(events) for events in story.values())
    fight_count = sum(
        event.get("type") == "fight"
        for events in story.values()
        for event in events
    )
    print("VALIDATION PASSED")
    print("- 50 campaign parts")
    print(f"- {event_count} normalized story events")
    print(f"- {fight_count} fight events")
    print("- 3 scripted-loss Arowh events")
    print("- 21 enemy definitions")
    print("- 3 rage tiers")
    print("- no banned stale runtime systems")
    return 0


if __name__ == "__main__":
    sys.exit(main())
