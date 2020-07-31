extends Node2D


signal pressed(road)


var travelled = false setget set_travelled
var _pulse = false
var _pulse_time = 0.0


func _process(delta):
	var c
	_pulse_time += delta
	if _pulse:
		c = 0.5 + sin(_pulse_time*5)*0.25
	else:
		c = 0.0
	$ColorRect.color = Color(c, c, c, $ColorRect.color.a)


func set_pulse(value):
	_pulse = value


func set_travelled(value):
	travelled = value
	modulate.a = 0.0 if value else 1.0


func _on_Button_pressed():
	emit_signal("pressed", self)
