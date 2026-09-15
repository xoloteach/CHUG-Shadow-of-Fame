extends Node
## Loads the three runtime data files and exposes explicit read-only queries.
##
## This intentionally avoids a generic key/value content API. Every public
## method below corresponds to data the game actually consumes.

const CAMPAIGN_PATH := "res://data/campaign.json"
const STORY_PATH := "res://data/story.json"
const COMBAT_PATH := "res://data/combat.json"

var _parts_by_id: Dictionary = {}
var _story_by_part: Dictionary = {}
var _combat: Dictionary = {}

func _ready() -> void:
    reload()

func reload() -> void:
    var campaign := _read_json_object(CAMPAIGN_PATH)
    var story := _read_json_object(STORY_PATH)
    _combat = _read_json_object(COMBAT_PATH)

    _parts_by_id.clear()
    for raw_part in campaign.get("parts", []):
        if raw_part is Dictionary:
            var part: Dictionary = raw_part
            _parts_by_id[int(part.get("id", 0))] = part

    _story_by_part = story.get("parts", {})
    _validate_runtime_data()

func get_part(part_id: int) -> Dictionary:
    var value = _parts_by_id.get(part_id, {})
    return value.duplicate(true) if value is Dictionary else {}

func get_story(part_id: int) -> Array:
    var value = _story_by_part.get(str(part_id), [])
    return value.duplicate(true) if value is Array else []

func get_first_enemy_for_part(part_id: int) -> int:
    for event in get_story(part_id):
        if event is Dictionary and event.get("type") == "fight":
            return int(event.get("enemy_id", 1))
    return 1

func get_player_stats() -> Dictionary:
    return _dictionary_copy(_combat.get("player", {}))

func get_enemy_stats(enemy_id: int) -> Dictionary:
    var enemies = _combat.get("enemies", {})
    if not (enemies is Dictionary):
        return {}
    return _dictionary_copy(enemies.get(str(enemy_id), enemies.get("1", {})))

func get_attack(attack_name: String) -> Dictionary:
    var attacks = _combat.get("attacks", {})
    if not (attacks is Dictionary):
        return {}
    return _dictionary_copy(attacks.get(attack_name, {}))

func get_resource_rules() -> Dictionary:
    return _dictionary_copy(_combat.get("resources", {}))

func get_movement_rules() -> Dictionary:
    return _dictionary_copy(_combat.get("movement", {}))

func get_rage_tier_for_part(part_id: int) -> int:
    var tiers = _combat.get("rage_tiers", {})
    if not (tiers is Dictionary):
        return 1

    var unlocked := 1
    for tier_key in tiers.keys():
        var tier := int(tier_key)
        var config = tiers[tier_key]
        if config is Dictionary and part_id >= int(config.get("unlock_part", 1)):
            unlocked = maxi(unlocked, tier)
    return unlocked

func get_rage_config(tier: int) -> Dictionary:
    var tiers = _combat.get("rage_tiers", {})
    if not (tiers is Dictionary):
        return {}
    return _dictionary_copy(tiers.get(str(tier), tiers.get("1", {})))

func _read_json_object(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("Missing runtime data: %s" % path)
        return {}

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Could not open runtime data: %s" % path)
        return {}

    var parsed = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        push_error("Runtime data must be a JSON object: %s" % path)
        return {}
    return parsed

func _dictionary_copy(value) -> Dictionary:
    return value.duplicate(true) if value is Dictionary else {}

func _validate_runtime_data() -> void:
    if _parts_by_id.size() != 50:
        push_error("Campaign must contain exactly 50 parts; found %d." % _parts_by_id.size())

    for part_id in range(1, 51):
        if not _parts_by_id.has(part_id):
            push_error("Campaign is missing Part %d." % part_id)
        if get_story(part_id).is_empty():
            push_error("Story is missing Part %d." % part_id)
