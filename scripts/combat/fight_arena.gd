class_name FightArena
extends Node3D
## Owns one encounter: fighter spawning, round score, HUD and result signal.

signal fight_finished(player_won: bool)

const FIGHTER_SCENE := preload("res://scenes/combat/Fighter.tscn")
const PLAYER_SPAWN := Vector3(-4.3, 0.0, 0.0)
const ENEMY_SPAWN := Vector3(4.3, 0.0, 0.0)

@onready var fighters_root: Node3D = %Fighters
@onready var player_hp: ProgressBar = %PlayerHP
@onready var enemy_hp: ProgressBar = %EnemyHP
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var rage_bar: ProgressBar = %RageBar
@onready var enemy_label: Label = %EnemyLabel
@onready var round_label: Label = %RoundLabel
@onready var message_label: Label = %MessageLabel

var enemy_id := 1
var rounds_to_win := 2
var rage_tier := 1
var player: Fighter
var enemy: Fighter
var player_wins := 0
var enemy_wins := 0
var round_number := 1
var round_locked := false

const INPUT_ACTIONS: Array[StringName] = [
    &"move_left", &"move_right", &"jump", &"attack_light", &"attack_heavy", &"rage"
]

func configure(configured_enemy_id: int, configured_rounds_to_win: int, configured_rage_tier: int) -> void:
    enemy_id = clampi(configured_enemy_id, 1, 21)
    rounds_to_win = clampi(configured_rounds_to_win, 1, 3)
    rage_tier = maxi(1, configured_rage_tier)

func _ready() -> void:
    enemy_label.text = "ENEMY %02d" % enemy_id
    _bind_touch_controls()
    _start_round()

func _exit_tree() -> void:
    _release_input_actions()

func _release_input_actions() -> void:
    for action in INPUT_ACTIONS:
        Input.action_release(action)

func _start_round() -> void:
    _clear_fighters()
    _release_input_actions()
    round_locked = true

    player = _spawn_fighter(true, 1, PLAYER_SPAWN)
    enemy = _spawn_fighter(false, enemy_id, ENEMY_SPAWN)
    player.set_opponent(enemy)
    enemy.set_opponent(player)
    player.set_commands_locked(true)
    enemy.set_commands_locked(true)

    var input := PlayerInputController.new()
    input.fighter = player
    player.add_child(input)

    var brain := EnemyBrain.new()
    brain.configure(enemy, player, enemy_id)
    enemy.add_child(brain)

    player.health_changed.connect(_on_player_health)
    enemy.health_changed.connect(_on_enemy_health)
    player.stamina_changed.connect(_on_stamina)
    player.rage_changed.connect(_on_rage)
    player.defeated.connect(_on_fighter_defeated)
    enemy.defeated.connect(_on_fighter_defeated)

    _sync_hud()
    round_label.text = "ROUND %d" % round_number
    message_label.text = "ROUND %d" % round_number
    get_tree().create_timer(0.8).timeout.connect(_begin_round)

func _begin_round() -> void:
    if player == null or enemy == null or player.health <= 0.0 or enemy.health <= 0.0:
        return
    round_locked = false
    player.set_commands_locked(false)
    enemy.set_commands_locked(false)
    message_label.text = "FIGHT"
    get_tree().create_timer(0.8).timeout.connect(_clear_message)

func _spawn_fighter(player_side: bool, configured_enemy_id: int, spawn_position: Vector3) -> Fighter:
    var fighter := FIGHTER_SCENE.instantiate() as Fighter
    fighter.configure(player_side, configured_enemy_id, rage_tier)
    fighter.position = spawn_position
    fighters_root.add_child(fighter)
    return fighter

func _clear_fighters() -> void:
    for child in fighters_root.get_children():
        child.free()

func _sync_hud() -> void:
    player_hp.max_value = player.max_health
    player_hp.value = player.health
    enemy_hp.max_value = enemy.max_health
    enemy_hp.value = enemy.health
    stamina_bar.max_value = player.max_stamina
    stamina_bar.value = player.stamina
    rage_bar.max_value = 100.0
    rage_bar.value = player.rage_meter

func _on_fighter_defeated(defeated_fighter: Fighter) -> void:
    if round_locked:
        return
    round_locked = true
    _release_input_actions()
    player.set_commands_locked(true)
    enemy.set_commands_locked(true)

    if defeated_fighter == enemy:
        player_wins += 1
        message_label.text = "ROUND WON"
    else:
        enemy_wins += 1
        message_label.text = "ROUND LOST"

    if player_wins >= rounds_to_win or enemy_wins >= rounds_to_win:
        var player_won := player_wins >= rounds_to_win
        message_label.text = "VICTORY" if player_won else "DEFEAT"
        get_tree().create_timer(1.2).timeout.connect(_finish_match.bind(player_won))
        return

    round_number += 1
    get_tree().create_timer(1.0).timeout.connect(_start_round)

func _finish_match(player_won: bool) -> void:
    fight_finished.emit(player_won)

func _on_player_health(current: float, maximum: float) -> void:
    player_hp.max_value = maximum
    player_hp.value = current

func _on_enemy_health(current: float, maximum: float) -> void:
    enemy_hp.max_value = maximum
    enemy_hp.value = current

func _on_stamina(current: float, maximum: float) -> void:
    stamina_bar.max_value = maximum
    stamina_bar.value = current

func _on_rage(current: float, maximum: float) -> void:
    rage_bar.max_value = maximum
    rage_bar.value = current

func _clear_message() -> void:
    if not round_locked:
        message_label.text = ""

func _bind_touch_controls() -> void:
    _bind_touch_button(%LeftButton, "move_left")
    _bind_touch_button(%RightButton, "move_right")
    _bind_touch_button(%JumpButton, "jump")
    _bind_touch_button(%LightButton, "attack_light")
    _bind_touch_button(%HeavyButton, "attack_heavy")
    _bind_touch_button(%RageButton, "rage")

func _bind_touch_button(button: Button, action: StringName) -> void:
    button.button_down.connect(_press_action.bind(action))
    button.button_up.connect(_release_action.bind(action))

func _press_action(action: StringName) -> void:
    Input.action_press(action)

func _release_action(action: StringName) -> void:
    Input.action_release(action)
