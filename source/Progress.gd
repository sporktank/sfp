extends Node


const FILENAME = "user://progress.json"


var _status = {}  # {puzzle: [played, solved, optimal], ...}

var show_splash = true


func _ready():
	_load_status()


func _save_status():
	var file = File.new()
	file.open(FILENAME, File.WRITE)
	file.store_line(to_json(_status))
	file.close()


func _load_status():
	var file = File.new()
	if not file.file_exists(FILENAME):
		_save_status()
	file.open(FILENAME, File.READ)
	_status = parse_json(file.get_line())
	file.close()


func reset():
	_status = {}
	_save_status()


func set_progress(puzzle, played=null, solved=null, optimal=null):
	if not _status.has(puzzle):
		_status[puzzle] = [false, false, false]
	if played != null:
		_status[puzzle][0] = played
	if solved != null:
		_status[puzzle][1] = solved
	if optimal != null:
		_status[puzzle][2] = optimal
	_save_status()


func get_progress(puzzle, played0_solved1_optimal2):
	if not _status.has(puzzle):
		_status[puzzle] = [false, false, false]
		_save_status()
	return _status[puzzle][played0_solved1_optimal2]


func check_first_time(title, instructions):
	if not get_progress(title, 0):
		instructions.visible = true
	set_progress(title, true)

# TEMP !!
#var _count = 0
#func _process(delta):
#	if Input.is_action_just_pressed("ui_down"):
#		_count += 1
#		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
#		yield(VisualServer, "frame_post_draw")
#		var img = get_viewport().get_texture().get_data()
#		img.flip_y()
#		img.save_png("user://screenshot" + str(_count) + ".png")
