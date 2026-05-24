extends KinematicBody2D

class_name BulletMLBulletInstance, "res://addons/bulletml/icons/comet-blue.svg"

## Emitted after _ready() is run.
signal bullet_ready(node)
## Emitted when destroying the bullet, before it is freed with queue_free().
signal destroyed(_type)

var _bullet : BulletMLBulletASTNode

var _runner: _BulletMLRunner

var _type : String

var _angle : float
var _speed : float

var _speed_x : float
var _speed_y : float
var _current_speed : float

var _last_angle : float = 0
var _last_speed : float = 0

var _accel_inc : Vector2
var _accel_end : Vector2

var _actions_local : Array

var _accel_horizontal : float
var _accel_vertical : float = 0
var _accel_term : float = 0

var _direction_tween: Tween
var _speed_tween: Tween
var _accel_tween: Tween

## Initialize position internally.
## Disable if you want to set the position via the editor.
export(bool) var initialize_position = true

## Exempt from bulletml_bullet_instances group.
## If you free bullets using call_group, this is useful to keep it alive.
export(bool) var exempt_from_group = false

## Whether the bullet rotates depending on its direction.
export(bool) var rotates = true

var _initial_position = Vector2()
var _shooter : String

func _ready():
    if not exempt_from_group:
        add_to_group("bulletml_bullet_instances")
    var screen = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
    if initialize_position:
        position = _initial_position
    if (position.x < 0 or position.x > screen.x) and (position.y < 0 or position.y > screen.y):
        set_physics_process(false)
        destroy()
        return
    _direction_tween = Tween.new()
    _direction_tween.playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS
    _speed_tween = Tween.new()
    _speed_tween.playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS
    _accel_tween = Tween.new()
    _accel_tween.playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS
    add_child(_direction_tween)
    add_child(_speed_tween)
    add_child(_accel_tween)
    
    if not _runner:
        _runner = _BulletMLRunner.new()
    if not _runner in get_children():
        add_child(_runner)
    _runner.connect("change_direction", self, "_on_change_direction")
    _runner.connect("change_speed", self, "_on_change_speed")
    _runner.connect("accel", self, "_on_accel")
    _runner.connect("vanish", self, "_on_vanish")

    emit_signal("bullet_ready", self)

func _physics_process(delta):
    var velocity = Vector2()
    velocity.x += cos(_angle+(PI/2)*3) * _speed
    velocity.y += sin(_angle+(PI/2)*3) * _speed
    velocity.x += _speed_x
    velocity.y += _speed_y
    move_and_slide(velocity)

## Used internally.
## Executes any BulletML corresponding to this bullet.
func start():
    visible = true
    _runner.stack = _actions_local.duplicate(true)
    _runner.run()

## Destroy the bullet.
## Emits the signal destroyed and runs queue_free().
func destroy():
    emit_signal("destroyed", _type)
    queue_free()

func _on_change_direction(change_direction : BulletMLChangeDirectionASTNode):
    var change_direction_angle = BulletMLContext._direction_to_value(change_direction.direction, self)
    _direction_tween.stop_all()
    _direction_tween.interpolate_property(self, "_angle", _angle, change_direction_angle, change_direction.term.get_value(), Tween.TRANS_LINEAR)
    _direction_tween.start()

func _on_change_speed(change_speed : BulletMLChangeSpeedASTNode):
    var change_speed_value = BulletMLContext._speed_to_value(change_speed.speed, _last_speed)
    _speed_tween.stop_all()
    _speed_tween.interpolate_property(self, "_speed", _speed, change_speed_value, change_speed.term.get_value(), Tween.TRANS_LINEAR)
    _speed_tween.start()

func _on_accel(accel : BulletMLAccelASTNode):
    _accel_end = BulletMLContext._accel_to_vec2_end(accel, _speed_x, _speed_y)
    _accel_tween.stop_all()
    _accel_tween.interpolate_property(self, "_speed_x", _speed_x, _accel_end.x, accel.term.get_value(), Tween.TRANS_LINEAR)
    _accel_tween.interpolate_property(self, "_speed_y", _speed_y, _accel_end.y, accel.term.get_value(), Tween.TRANS_LINEAR)
    _accel_tween.start()

func _on_vanish():
    destroy()
