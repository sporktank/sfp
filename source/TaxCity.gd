extends Control


var _player_pos = [0,0]
var _tax = 0.0
var _finished = false


onready var _header = $Header
onready var _player = $Body/Center/Player
onready var _start = $Body/Center/Start
onready var _exit = $Body/Center/Exit
onready var _tax_label = $Body/Center/Tax
onready var _roads = $Body/Center/Roads.get_children()
onready var _success = $Body/Center/Success
onready var _instructions = $Body/Center/Instructions
onready var _money_up = $MoneyUp
onready var _money_down = $MoneyDown


func _ready():
	get_tree().set_quit_on_go_back(false)
	Progress.check_first_time(_header.title, _instructions)
	_update_pulses()


func _update_tax():
	_tax_label.text = ("-" if _tax < 0.0 else "+" if _tax > 0.0 else "") + "$%.2f" % [abs(_tax)]
	_tax_label.add_color_override("font_color", Color(0 if _tax >= 0 else 1, 0, 0, 1))


func _update_pulses():
	for road in _roads:
		var x = int(road.name.substr(4, 1))
		var y = int(road.name.substr(5, 1))
		var points = [[x-1, y], [x+1, y]] if x % 2 == 1 else [[x, y-1], [x, y+1]]
		road.set_pulse(_player_pos in points and not road.travelled and not _finished)


func _travel_to(point, road):
	
	var dx = point[0] - _player_pos[0]
	var dy = point[1] - _player_pos[1]
	var new_tax = _tax
	if dx < 0: new_tax += 20
	if dx > 0: new_tax -= 20
	if dy < 0: new_tax /= 2
	if dy > 0: new_tax *= 2
	if new_tax < _tax:
		_money_down.play()
	elif new_tax > _tax:
		_money_up.play()
	_tax = new_tax
	_update_tax()
	road.travelled = true
	
	var start = _start.global_position
	var steps = (_exit.global_position - start) / 4.0 / 2.0
	var x = start.x + point[0]*steps.x
	var y = start.y + point[1]*steps.y
	_player.global_position = Vector2(x, y)
	_player_pos = point
	_update_pulses()
	
	if _player_pos == [8,8]:
		_finished = true
		if _tax >= 0.0:
			Progress.set_progress(_header.title, true, true if _tax >= 0.0 else null, true if _tax > 0.0 else null)
			_header.update_status()
			_success.show(_tax > 0.0)


func _on_Road00_pressed(road):  # Oops named Road00, not sure how to refactor at the moment.
	if road.travelled or _finished:
		return
	var x = int(road.name.substr(4, 1))
	var y = int(road.name.substr(5, 1))
	assert((x % 2) != (y % 2))
	var points = [[x-1, y], [x+1, y]] if x % 2 == 1 else [[x, y-1], [x, y+1]]
	if _player_pos in points:
		_travel_to(points[1] if _player_pos == points[0] else points[0], road)


func _on_Footer_instructions_pressed():
	_instructions.visible = true
