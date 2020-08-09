extends Control


enum STATE {PLAYING, PROVING, SOLVED}


onready var NUM_FLOORS = $Body/Center/Floors.get_child_count()


var _state = STATE.PLAYING
var _history = []
var _princess_floor = null
var _opening_door = false
var _night_num = 1
var _pending_floors = []
var _intend_show_path = false
var _path_shown = false
var _princess_path = null
var _backup_path = null
var _backup_floor = null
var _speed_up = 1.0


onready var _header = $Header
onready var _night_text = $Body/Center/Night
onready var _tween = $Tween
onready var _floors = $Body/Center/Floors
onready var _prince = $Body/Center/Prince
onready var _princess = $Body/Center/Princess
onready var _prince_x = $Body/Center/PrinceX
onready var _princess_x = $Body/Center/PrincessX
onready var _ghost_prince = $Body/Center/GhostPrince
onready var _ghost_princess = $Body/Center/GhostPrincess
onready var _success = $Body/Center/Success
onready var _instructions = $Body/Center/Instructions


func _ready():
	get_tree().set_quit_on_go_back(false)
	randomize()
	Progress.check_first_time(_header.title, _instructions)


func _process(delta):
	_night_text.text = "NIGHT\n#" + str(_night_num)
	# TODO: This convoluted logic to delay showing the path is not nice. Learn a better way.
	if _intend_show_path and _pending_floors.size() == 0 and not _opening_door and _state == STATE.PLAYING:
		_state = STATE.PROVING
		if not _path_shown:
			_show_path()
		_path_shown = true


func _show_path():
	
	if _princess_path == null:
		var paths = _generate_possible_paths(_history)
		_princess_path = paths[randi() % paths.size()]
		_princess_floor = _princess_path[-1]
	
	_tween.interpolate_property(_prince,   "global_position:x", _prince.global_position.x,   _prince_x.global_position.x,   1.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.start()
	yield(_tween, "tween_all_completed")
	
	_night_num = 1
	
	_ghost_princess.visible = true
	_ghost_princess.global_position.y = _compute_floor_y(_princess_path[0])
	if _history.size() > 0:
		_ghost_prince.visible = true
		yield(get_tree().create_timer(2.5), "timeout")
		#_ghost_prince.global_position.y = _compute_floor_y(_history[0])
		#yield(_floors.get_node("Floor"+str(_history[0])).open(false, true, 2.0), "completed")
		var y = _compute_floor_y(_history[0])
		_tween.interpolate_property(_ghost_prince, "global_position:y", _ghost_prince.global_position.y, y, 0.8, Tween.TRANS_QUART, Tween.EASE_OUT)
		_tween.start()
		yield(_tween, "tween_all_completed")
		yield(_floors.get_node("Floor"+str(_history[0])).open(false, true, 2.0), "completed")
		#yield(get_tree().create_timer(0.2), "timeout")
	print(_history.size(), " ", _princess_path.size())
	for i in range(1, _princess_path.size()):
		var y = _compute_floor_y(_princess_path[i])
		_tween.interpolate_property(_ghost_princess, "global_position:y", _ghost_princess.global_position.y, y, 0.8, Tween.TRANS_QUART, Tween.EASE_OUT)
		_tween.start()
		yield(_tween, "tween_all_completed")
		_night_num += 1
		yield(get_tree().create_timer(0.2), "timeout")
		if i < _history.size():
			y = _compute_floor_y(_history[i])
			_tween.interpolate_property(_ghost_prince, "global_position:y", _ghost_prince.global_position.y, y, 0.8, Tween.TRANS_QUART, Tween.EASE_OUT)
			_tween.start()
			yield(_tween, "tween_all_completed")
			yield(_floors.get_node("Floor"+str(_history[i])).open(false, true, 2.0), "completed")
			yield(get_tree().create_timer(0.2), "timeout")
	
	_princess.visible = true
	_princess.global_position.y = _compute_floor_y(_princess_floor)
	_tween.interpolate_property(_princess, "global_position:x", _princess.global_position.x, _princess_x.global_position.x, 1.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.start()
	yield(_tween, "tween_all_completed")


func _generate_possible_paths(h):
	var paths = []
	var n = h.size()
	for start in range(1, NUM_FLOORS+1):
		for steps in range(int(pow(2,n))):
			var f = start
			var success = true
			for i in range(n):
				if f == h[i]:
					success = false
					break
				f += 1 if int(pow(2,i)) & steps else -1
				if f <= 0 or f >= NUM_FLOORS+1:
					success = false
					break
			if success:
				var path = [start]
				for i in range(n):
					path.append(path[-1] + (1 if int(pow(2,i)) & steps else -1))
				paths.append(path)
	return paths


func _compute_floor_y(floor_num):
	return _floors.get_node("Floor"+str(floor_num)).global_position.y


func _move_prince(floor_num):
	var y = _compute_floor_y(floor_num)
	_tween.interpolate_property(_prince, "global_position:y", _prince.global_position.y, y, 0.3/_speed_up, Tween.TRANS_QUART, Tween.EASE_OUT)
	_tween.start()
	yield(_tween, "tween_all_completed")


func _on_Floor_pressed(floor_):
	if _state != STATE.PLAYING:
		return
	if _opening_door:
		_pending_floors.append(floor_)
		return
	var floor_num = int(floor_.name.substr(5, -1))
	#prints(floor_num, _princess_path, _princess_floor, _backup_path, _backup_floor)
	_history.append(floor_num)
	_opening_door = true
	if _princess_floor == null:
		yield(_move_prince(floor_num), "completed")
		yield(floor_.open(false, true, _speed_up), "completed")
		_night_num += 1
		if _history.size() == (NUM_FLOORS-2)*2-1:
			# At this crtical point, concretely choose a path for the princess.
			var paths = _generate_possible_paths(_history)
			print("Number of possible paths for princess: ", paths.size())
			var last = {} ; for p in paths: last[p[-1]] = true
			print("Number of unique last floors: ", last.keys().size())
			_princess_path = paths[randi() % paths.size()]
			_princess_floor = _princess_path[-1]
			print("Randomly chose floor number: ", _princess_floor)
			# Subtle issue where player can luckily guess optimal without playing optimally.
			if last.keys().size() > 1:
				paths.shuffle()
				for p in paths:
					if p[-1] != _princess_floor:
						_backup_path = p
						_backup_floor = null
						break
			print("Backup path: ", _backup_path)
	else:
		if floor_num == _princess_floor and _backup_path != null:
			_princess_path = _backup_path
			_princess_floor = _backup_path[-1]
			_backup_path = null
		elif floor_num == _princess_floor and _backup_floor != null:
			_princess_path[-1] = _backup_floor
			_princess_floor = _backup_floor
			_backup_floor = null
		if floor_num == _backup_floor:
			_backup_floor = null
		if floor_num == _princess_floor:
			yield(_move_prince(floor_num), "completed")
			yield(floor_.open(true, false, _speed_up), "completed")
			_pending_floors.clear()
			_state = STATE.SOLVED
			Progress.set_progress(_header.title, true, true, true if _history.size() == (NUM_FLOORS-2)*2 else null)
			_header.update_status()
			_success.show(_history.size() == (NUM_FLOORS-2)*2)
		else:
			yield(_move_prince(floor_num), "completed")
			yield(floor_.open(false, true, _speed_up), "completed")
			_night_num += 1
			if _princess_floor == 1:
				_princess_floor += 1
				_backup_floor = null
			elif _princess_floor == NUM_FLOORS:
				_princess_floor -= 1
				_backup_floor = null
			else:
				var diff = 2*(randi() % 2) - 1
				_backup_floor = _princess_floor - diff
				_princess_floor += diff
			_princess_path.append(_princess_floor)
		_backup_path = null
		print("Princess at %s with backup %s" % [_princess_floor, _backup_floor])
	if _speed_up < 2.5:
		_speed_up += 0.5
	_opening_door = false
	if _pending_floors.size() > 0:
		_on_Floor_pressed(_pending_floors.pop_front())


func _on_Show_pressed():
	_intend_show_path = true


func _on_Footer_instructions_pressed():
	_instructions.visible = true
