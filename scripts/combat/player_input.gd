class_name PlayerInputController
extends Node
## Translates local input actions into Fighter commands.

var fighter: Fighter

func _physics_process(_delta: float) -> void:
    if fighter == null:
        return

    fighter.request_move(Input.get_axis("move_left", "move_right"))

    if Input.is_action_just_pressed("jump"):
        fighter.request_jump()
    if Input.is_action_just_pressed("attack_light"):
        fighter.request_attack("light")
    if Input.is_action_just_pressed("attack_heavy"):
        fighter.request_attack("heavy")
    if Input.is_action_just_pressed("rage"):
        fighter.request_rage()
