extends Node
## Persistence only. No gameplay rules live here.

const SAVE_PATH := "user://chug_save.json"

signal progress_loaded
signal progress_saved
signal progress_reset

var progress: Dictionary = {}

func _ready() -> void:
    load_progress()

func default_progress() -> Dictionary:
    return {
        "current_part": 1,
        "completed_parts": [],
        "campaign_complete": false,
    }

func load_progress() -> void:
    progress = default_progress()

    if not FileAccess.file_exists(SAVE_PATH):
        save_progress()
        progress_loaded.emit()
        return

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_warning("Could not read save file. Using fresh progress.")
        progress_loaded.emit()
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary and _is_valid_progress(parsed):
        var completed: Array = []
        for value in parsed.get("completed_parts", []):
            var part_id := int(value)
            if part_id >= 1 and part_id <= 50 and not completed.has(part_id):
                completed.append(part_id)
        progress = {
            "current_part": int(parsed.get("current_part", 1)),
            "completed_parts": completed,
            "campaign_complete": bool(parsed.get("campaign_complete", completed.has(50))),
        }
    else:
        push_warning("Save file did not match the current lean schema. Using fresh progress.")

    progress_loaded.emit()

func save_progress() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Could not write save file: %s" % SAVE_PATH)
        return
    file.store_string(JSON.stringify(progress, "  "))
    progress_saved.emit()

func reset_progress() -> void:
    progress = default_progress()
    save_progress()
    progress_reset.emit()

func _is_valid_progress(value: Dictionary) -> bool:
    var part := int(value.get("current_part", 0))
    var completed = value.get("completed_parts", null)
    return part >= 1 and part <= 50 and completed is Array
