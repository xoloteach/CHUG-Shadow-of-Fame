extends Node
## Owns campaign progression and global input bootstrap.
## Authored content belongs to GameData; disk I/O belongs to SaveStore.

func _ready() -> void:
    _ensure_input_actions()

func get_current_part() -> int:
    return int(SaveStore.progress.get("current_part", 1))

func get_current_part_data() -> Dictionary:
    return GameData.get_part(get_current_part())

func get_current_rage_tier() -> int:
    return GameData.get_rage_tier_for_part(get_current_part())

func is_campaign_complete() -> bool:
    return bool(SaveStore.progress.get("campaign_complete", false))

func complete_part(part_id: int) -> void:
    if part_id != get_current_part():
        return

    var completed: Array = SaveStore.progress.get("completed_parts", [])
    if not completed.has(part_id):
        completed.append(part_id)
    SaveStore.progress["completed_parts"] = completed

    if part_id < 50:
        SaveStore.progress["current_part"] = part_id + 1
    else:
        SaveStore.progress["campaign_complete"] = true

    SaveStore.save_progress()

func reset_progress() -> void:
    SaveStore.reset_progress()

func _ensure_input_actions() -> void:
    _ensure_key_action("move_left", [KEY_A, KEY_LEFT])
    _ensure_key_action("move_right", [KEY_D, KEY_RIGHT])
    _ensure_key_action("jump", [KEY_W, KEY_SPACE, KEY_UP])
    _ensure_key_action("attack_light", [KEY_J])
    _ensure_key_action("attack_heavy", [KEY_K])
    _ensure_key_action("rage", [KEY_R])

func _ensure_key_action(action: StringName, physical_keys: Array) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    if not InputMap.action_get_events(action).is_empty():
        return

    for keycode in physical_keys:
        var event := InputEventKey.new()
        event.physical_keycode = int(keycode)
        InputMap.action_add_event(action, event)
