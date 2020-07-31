extends Node2D


signal pressed(floor_)


onready var _princess = $Princess
onready var _tween = $Tween
onready var _door_pivot = $DoorPivot
onready var _walls_pivot = $WallsPivot
onready var _door_open = $DoorOpen
onready var _door_close = $DoorClose


func _on_Button_pressed():
	emit_signal("pressed", self)


func open(has_princess, close, speed_up=1.0):
	_princess.visible = has_princess
	_door_open.play()
	_tween.interpolate_property(_door_pivot,  "scale:x", 1.0, 0.20, 0.6/speed_up, Tween.TRANS_CIRC, Tween.EASE_OUT)
	_tween.interpolate_property(_walls_pivot, "scale:x", 1.0, 0.05, 0.6/speed_up, Tween.TRANS_CIRC, Tween.EASE_OUT)
	_tween.start()
	yield(_tween, "tween_all_completed")
	if close:
		yield(get_tree().create_timer(0.2/speed_up), "timeout")
		_door_close.play()
		_tween.interpolate_property(_door_pivot,  "scale:x", 0.20, 1.0, 0.2/speed_up, Tween.TRANS_CIRC, Tween.EASE_IN)
		_tween.interpolate_property(_walls_pivot, "scale:x", 0.05, 1.0, 0.2/speed_up, Tween.TRANS_CIRC, Tween.EASE_IN)
		_tween.start()
		yield(_tween, "tween_all_completed")

