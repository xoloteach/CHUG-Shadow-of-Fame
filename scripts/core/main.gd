extends Control
## Top-level flow coordinator.
##
## Responsibilities are intentionally narrow:
## menu -> story event -> fight -> story event -> part completion.

const FIGHT_ARENA_SCENE := preload("res://scenes/combat/FightArena.tscn")

@onready var menu: VBoxContainer = %Menu
@onready var part_label: Label = %PartLabel
@onready var continue_button: Button = %ContinueButton
@onready var quick_fight_button: Button = %QuickFightButton
@onready var reset_button: Button = %ResetButton
@onready var story_panel: StoryPanel = %StoryPanel

var story := StorySequence.new()
var active_fight: Node = null
var active_part := 1
var pending_fight_event: Dictionary = {}
var quick_fight_mode := false

func _ready() -> void:
    continue_button.pressed.connect(_start_campaign_part)
    quick_fight_button.pressed.connect(_start_quick_fight)
    reset_button.pressed.connect(_reset_progress)
    story_panel.action_requested.connect(_on_story_action)
    _show_menu()

func _show_menu() -> void:
    story_panel.close()
    menu.visible = true
    active_part = GameSession.get_current_part()
    var part := GameData.get_part(active_part)
    var title := str(part.get("title", "PART %d" % active_part))
    var rage_tier := GameData.get_rage_tier_for_part(active_part)
    if GameSession.is_campaign_complete():
        part_label.text = "CAMPAIGN COMPLETE\nPART 50 — %s" % title
        continue_button.disabled = true
    else:
        part_label.text = "PART %02d — %s\nRAGE TIER %d" % [active_part, title, rage_tier]
        continue_button.disabled = false

func _start_campaign_part() -> void:
    quick_fight_mode = false
    active_part = GameSession.get_current_part()
    story.load_events(GameData.get_story(active_part))
    menu.visible = false
    _advance_story()

func _advance_story() -> void:
    var event := story.next_event()
    if event.is_empty():
        _complete_active_part()
        return

    pending_fight_event = event if event.get("type") == "fight" else {}
    var part := GameData.get_part(active_part)
    story_panel.present(active_part, str(part.get("title", "")), event)

func _on_story_action(action: String) -> void:
    match action:
        "fight":
            _start_fight(pending_fight_event)
        "complete":
            _complete_active_part()
        _:
            _advance_story()

func _start_quick_fight() -> void:
    quick_fight_mode = true
    active_part = GameSession.get_current_part()
    var enemy_id := GameData.get_first_enemy_for_part(active_part)
    var event := {
        "type": "fight",
        "enemy_id": enemy_id,
        "required_result": "win",
        "rounds_to_win": 2,
    }
    menu.visible = false
    _start_fight(event)

func _start_fight(event: Dictionary) -> void:
    story_panel.close()
    pending_fight_event = event.duplicate(true)

    active_fight = FIGHT_ARENA_SCENE.instantiate()
    active_fight.configure(
        int(event.get("enemy_id", 1)),
        int(event.get("rounds_to_win", 2)),
        GameData.get_rage_tier_for_part(active_part)
    )
    add_child(active_fight)
    active_fight.fight_finished.connect(_on_fight_finished)

func _on_fight_finished(player_won: bool) -> void:
    if active_fight != null:
        active_fight.queue_free()
        active_fight = null

    if quick_fight_mode:
        quick_fight_mode = false
        _show_menu()
        return

    var required_result := str(pending_fight_event.get("required_result", "win"))
    var expected_won := required_result == "win"
    if player_won != expected_won:
        _show_menu()
        return

    pending_fight_event.clear()
    _advance_story()

func _complete_active_part() -> void:
    story.clear()
    pending_fight_event.clear()
    GameSession.complete_part(active_part)
    _show_menu()

func _reset_progress() -> void:
    story.clear()
    pending_fight_event.clear()
    GameSession.reset_progress()
    _show_menu()
