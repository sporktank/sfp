tool
extends Node2D


signal pressed


export(String) var puzzle_name = "NAME"


onready var _button = $Button
onready var _solved = $Solved
onready var _optimal = $Optimal
onready var _click = $Click


func set_status(solved, optimal):
	_solved.frame = int(solved)
	_optimal.frame = int(optimal)


func _process(delta):
	_button.text = puzzle_name


func _on_Button_pressed():
	_click.play()
	yield(get_tree().create_timer(0.05), "timeout")
	emit_signal("pressed")
