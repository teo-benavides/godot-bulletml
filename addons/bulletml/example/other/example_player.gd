extends KinematicBody2D

const SPEED = 200

func _physics_process(delta):
    var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var velocity = input * SPEED
    move_and_slide(velocity)
    
    BulletMLContext.player_position = global_position
