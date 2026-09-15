class_name EnemyBrain
extends Node
## Minimal deterministic-purpose AI: approach, pause, attack.
## It contains decisions only; damage and physics remain inside Fighter.

var fighter: Fighter
var opponent: Fighter
var _think_remaining := 0.0
var _aggression := 0.45

func configure(controlled_fighter: Fighter, target: Fighter, enemy_id: int) -> void:
    fighter = controlled_fighter
    opponent = target
    var stats := GameData.get_enemy_stats(enemy_id)
    _aggression = clampf(float(stats.get("aggression", 0.45)), 0.0, 1.0)

func _physics_process(delta: float) -> void:
    if fighter == null or opponent == null or fighter.health <= 0.0:
        return

    var dx := opponent.global_position.x - fighter.global_position.x
    var distance := absf(dx)
    if distance > 1.9:
        fighter.request_move(signf(dx))
        return

    fighter.request_move(0.0)
    _think_remaining -= delta
    if _think_remaining > 0.0:
        return

    _think_remaining = randf_range(0.25, 0.65)
    if randf() <= _aggression:
        fighter.request_attack("heavy" if randf() < 0.30 else "light")
    elif randf() < 0.12:
        fighter.request_jump()
