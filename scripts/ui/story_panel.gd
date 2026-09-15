class_name StoryPanel
extends PanelContainer
## Displays one normalized story event and emits a semantic action.

signal action_requested(action: String)

@onready var header: Label = %Header
@onready var story_text: RichTextLabel = %StoryText
@onready var action_button: Button = %ActionButton

var current_action := "continue"

func _ready() -> void:
    action_button.pressed.connect(_on_action_pressed)

func present(part_id: int, part_title: String, event: Dictionary) -> void:
    visible = true
    header.text = "PART %02d — %s" % [part_id, part_title]
    story_text.text = str(event.get("text", ""))

    var color := Color("e8e1d2")
    var color_text := str(event.get("color", ""))
    if not color_text.is_empty() and Color.html_is_valid(color_text):
        color = Color(color_text)
    story_text.add_theme_color_override("default_color", color)

    match str(event.get("type", "text")):
        "fight":
            current_action = "fight"
            action_button.text = "FIGHT"
        "end":
            current_action = "complete"
            action_button.text = "COMPLETE PART"
        _:
            current_action = "continue"
            action_button.text = "CONTINUE"

func close() -> void:
    visible = false

func _on_action_pressed() -> void:
    action_requested.emit(current_action)
