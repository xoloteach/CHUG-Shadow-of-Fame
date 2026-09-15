class_name Fighter
extends CharacterBody3D
## One combatant. Owns movement physics, resources, attack timing and damage.
## Input/AI decisions are intentionally delegated to controller nodes.

signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal rage_changed(current: float, maximum: float)
signal defeated(fighter: Fighter)

@onready var visual_root: Node3D = %VisualRoot
@onready var model_root: Node3D = %ModelRoot
@onready var debug_visual: Node3D = %DebugVisual
@onready var debug_body: MeshInstance3D = %DebugBody
@onready var debug_head: MeshInstance3D = %DebugHead

var is_player := false
var enemy_id := 1
var rage_tier := 1
var opponent: Fighter = null

var max_health := 100.0
var health := 100.0
var move_speed := 6.0
var base_damage := 10.0
var defense := 0.0
var max_stamina := 100.0
var stamina := 100.0
var jump_speed := 10.5
var minimum_health := 0.0

enum ActionState { NEUTRAL, ATTACKING, HIT_STUN, DEFEATED }

var rage_meter := 0.0
var rage_active := false
var move_axis := 0.0
var facing := 1.0
var action_state := ActionState.NEUTRAL
var commands_locked := false

var _gravity := 24.0
var _arena_half_width := 12.5
var _resource_rules: Dictionary = {}
var _rage_rules: Dictionary = {}
var _attack_name := ""
var _attack_elapsed := 0.0
var _attack_hit_done := false
var _hit_stun_remaining := 0.0
var _defeat_emitted := false

func configure(player_side: bool, configured_enemy_id: int, configured_rage_tier: int) -> void:
    is_player = player_side
    enemy_id = configured_enemy_id
    rage_tier = maxi(1, configured_rage_tier)

func _ready() -> void:
    _load_stats()
    _load_visual()
    _emit_resource_state()

func set_opponent(value: Fighter) -> void:
    opponent = value

func set_commands_locked(locked: bool) -> void:
    commands_locked = locked
    if locked:
        move_axis = 0.0

func request_move(axis: float) -> void:
    move_axis = clampf(axis, -1.0, 1.0) if not commands_locked and action_state == ActionState.NEUTRAL else 0.0

func request_jump() -> void:
    if not commands_locked and action_state == ActionState.NEUTRAL and is_on_floor():
        velocity.y = jump_speed

func request_attack(attack_name: String) -> void:
    if commands_locked or action_state != ActionState.NEUTRAL:
        return

    var attack := GameData.get_attack(attack_name)
    if attack.is_empty():
        return

    var cost := float(attack.get("stamina_cost", 0.0))
    if stamina < cost:
        return

    stamina -= cost
    stamina_changed.emit(stamina, max_stamina)
    _attack_name = attack_name
    _attack_elapsed = 0.0
    _attack_hit_done = false
    action_state = ActionState.ATTACKING

func request_rage() -> void:
    if commands_locked or action_state != ActionState.NEUTRAL or not is_player or rage_active or rage_meter < 100.0:
        return
    rage_active = true
    rage_meter = 100.0
    rage_changed.emit(rage_meter, 100.0)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= _gravity * delta

    match action_state:
        ActionState.DEFEATED:
            move_axis = 0.0
            velocity.x = move_toward(velocity.x, 0.0, 20.0 * delta)
        ActionState.HIT_STUN:
            _hit_stun_remaining = maxf(0.0, _hit_stun_remaining - delta)
            velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
            if _hit_stun_remaining <= 0.0:
                action_state = ActionState.NEUTRAL
        ActionState.ATTACKING:
            _update_attack(delta)
            velocity.x = move_toward(velocity.x, 0.0, 18.0 * delta)
        ActionState.NEUTRAL:
            var speed_multiplier := float(_rage_rules.get("speed_multiplier", 1.0)) if rage_active else 1.0
            velocity.x = move_axis * move_speed * speed_multiplier

    _recover_resources(delta)
    _face_opponent()
    move_and_slide()
    position.x = clampf(position.x, -_arena_half_width, _arena_half_width)
    position.z = 0.0

func receive_hit(raw_damage: float, direction: float, attack_name: String) -> void:
    if health <= 0.0:
        return

    var attack := GameData.get_attack(attack_name)
    var damage := maxf(1.0, raw_damage - defense)
    if rage_active:
        damage *= float(_rage_rules.get("damage_taken_multiplier", 1.0))

    health = maxf(minimum_health, health - damage)
    velocity.x = direction * float(attack.get("knockback_x", 3.5))
    velocity.y = float(attack.get("knockback_y", 1.2))
    _hit_stun_remaining = float(attack.get("hit_stun", 0.16))
    action_state = ActionState.DEFEATED if health <= 0.0 else ActionState.HIT_STUN

    if is_player:
        rage_meter = minf(100.0, rage_meter + float(_resource_rules.get("rage_gain_when_hit", 0.0)))
        rage_changed.emit(rage_meter, 100.0)

    health_changed.emit(health, max_health)
    if health <= 0.0 and not _defeat_emitted:
        _defeat_emitted = true
        defeated.emit(self)

func _load_stats() -> void:
    var stats := GameData.get_player_stats() if is_player else GameData.get_enemy_stats(enemy_id)
    var movement := GameData.get_movement_rules()

    max_health = float(stats.get("hp", 100.0))
    health = max_health
    move_speed = float(stats.get("speed", 6.0))
    base_damage = float(stats.get("damage", 10.0))
    defense = float(stats.get("defense", 0.0))
    max_stamina = float(stats.get("stamina", 100.0)) if is_player else 100.0
    stamina = max_stamina
    jump_speed = float(stats.get("jump_speed", 10.5))
    minimum_health = float(stats.get("minimum_hp", 0.0))

    _gravity = float(movement.get("gravity", 24.0))
    _arena_half_width = float(movement.get("arena_half_width", 12.5))
    _resource_rules = GameData.get_resource_rules()
    _rage_rules = GameData.get_rage_config(rage_tier)

func _update_attack(delta: float) -> void:
    var attack := GameData.get_attack(_attack_name)
    var duration := float(attack.get("duration", 0.3))
    var hit_at := duration * float(attack.get("hit_at_ratio", 0.5))

    _attack_elapsed += delta
    if not _attack_hit_done and _attack_elapsed >= hit_at:
        _attack_hit_done = true
        _try_hit(attack)

    if _attack_elapsed >= duration:
        _attack_name = ""
        _attack_elapsed = 0.0
        _attack_hit_done = false
        action_state = ActionState.NEUTRAL

func _try_hit(attack: Dictionary) -> void:
    if opponent == null or opponent.health <= 0.0:
        return

    var distance := absf(opponent.global_position.x - global_position.x)
    if distance > float(attack.get("range", 1.75)):
        return

    var multiplier := float(attack.get("damage_multiplier", 1.0))
    if rage_active:
        multiplier *= float(_rage_rules.get("damage_multiplier", 1.0))

    opponent.receive_hit(base_damage * multiplier, facing, _attack_name)

    if is_player:
        var rage_key := "rage_gain_heavy" if _attack_name == "heavy" else "rage_gain_light"
        rage_meter = minf(100.0, rage_meter + float(_resource_rules.get(rage_key, 0.0)))
        rage_changed.emit(rage_meter, 100.0)

func _recover_resources(delta: float) -> void:
    if is_player and stamina < max_stamina:
        stamina = minf(max_stamina, stamina + float(_resource_rules.get("stamina_regen_per_second", 0.0)) * delta)
        stamina_changed.emit(stamina, max_stamina)

    if rage_active:
        rage_meter = maxf(0.0, rage_meter - float(_rage_rules.get("drain_per_second", 15.0)) * delta)
        if rage_meter <= 0.0:
            rage_active = false
        rage_changed.emit(rage_meter, 100.0)

func _face_opponent() -> void:
    if opponent == null:
        return
    facing = 1.0 if opponent.global_position.x >= global_position.x else -1.0
    visual_root.rotation.y = 0.0 if facing > 0.0 else PI

func _load_visual() -> void:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("d49a22") if is_player else Color("7b1634")
    material.roughness = 0.6
    debug_body.material_override = material
    debug_head.material_override = material

    var model_path := "res://assets/models/characters/chug.glb" if is_player else "res://assets/models/characters/enemy.glb"
    if not ResourceLoader.exists(model_path):
        return

    var resource = load(model_path)
    if resource is PackedScene:
        debug_visual.visible = false
        model_root.add_child(resource.instantiate())

func _emit_resource_state() -> void:
    health_changed.emit(health, max_health)
    stamina_changed.emit(stamina, max_stamina)
    rage_changed.emit(rage_meter, 100.0)
