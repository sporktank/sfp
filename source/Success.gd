extends Node2D


onready var _sprite = $AnimatedSprite
onready var _tween = $Tween


func show(optimal=false):
	_sprite.frame = int(optimal)
	_sprite.position.x = get_viewport().size.x
	visible = true
	yield(get_tree().create_timer(0.3), "timeout")
	_tween.interpolate_property(_sprite, "position:x", _sprite.position.x, 0.0, 0.2, Tween.TRANS_BACK, Tween.EASE_OUT)
	_tween.start()
	yield(_tween, "tween_all_completed")
	yield(get_tree().create_timer(2.0), "timeout")
	_tween.interpolate_property(_sprite, "position:x", 0.0, -get_viewport().size.x, 0.2, Tween.TRANS_QUINT, Tween.EASE_OUT)
	_tween.start()
	yield(_tween, "tween_all_completed")
	visible = false
