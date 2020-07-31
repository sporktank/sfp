#tool
extends Control


export(String) var title = "TITLE"


onready var _title = $Center/Title
onready var _solved = $Center/Solved
onready var _optimal = $Center/Optimal


func _ready():
	update_status()


func update_status():
	set_status(Progress.get_progress(title, 1), Progress.get_progress(title, 2))


func _process(delta):
	_title.text = title


func set_status(solved, optimal):
	_solved.frame = int(solved)
	_optimal.frame = int(optimal)
