extends KinematicBody2D


signal touched
signal released


enum STATE {EMPTY, AVAILABLE, PRESENT, FREE}


var _state = STATE.FREE


onready var _empty = $Empty
onready var _available = $Available
onready var _present = $Present
onready var _debug = $Debug
onready var _collision = $CollisionShape2D


func get_radius():
	return _present.texture.get_size().x * _present.scale.x * 0.5


func set_state_empty():
	_state = STATE.EMPTY
	call_deferred("_update_visible")


func set_state_available():
	_state = STATE.AVAILABLE
	call_deferred("_update_visible")
	

func set_state_present():
	_state = STATE.PRESENT
	call_deferred("_update_visible")
	

func set_state_free():
	_state = STATE.PRESENT
	call_deferred("_update_visible")


func is_present():
	return _state == STATE.PRESENT


func is_available():
	return _state == STATE.AVAILABLE


func set_debug(text):
	_debug.text = text


func _update_visible():
	_empty.visible = _state == STATE.EMPTY
	_available.visible = _state == STATE.AVAILABLE
	_present.visible = _state == STATE.PRESENT or _state == STATE.FREE
	_collision.disabled = _state == STATE.EMPTY or _state == STATE.AVAILABLE


func _on_Button_button_down():
	emit_signal("touched")


func _on_Button_button_up():
	emit_signal("released")
