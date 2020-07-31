extends Control


enum STATE {STILL, DRAGGING, FINISHED}

const GRID_WIDTH = 6
const GRID_HEIGHT = 6

const INITIAL_COINS = [[2,2],[3,2],[4,2],[1,3],[2,3],[3,3]]

var _state = STATE.STILL
var _goto_position = Vector2()
var _move_count = 0
var _coin_scene = preload("res://source/Coin.tscn")
var _coin_refs = []

onready var _header = $Header
onready var _coin_grid = $Body/Center/CoinGrid
onready var _free_coin = $Body/Center/FreeCoin
onready var _success = $Body/Center/Success
onready var _moves_label = $Body/Center/Rules/Moves
onready var _instructions = $Body/Center/Instructions
onready var _coin = $Coin


func _ready():
	get_tree().set_quit_on_go_back(false)
	_fill_coin_grid()
	_reset_grid()
	Progress.check_first_time(_header.title, _instructions)


func _input(event):
	match _state:
		STATE.DRAGGING:
			if event is InputEventMouseMotion:
				#_free_coin.global_position = event.position
				_goto_position = event.position


func _physics_process(delta):
	match _state:
		STATE.DRAGGING:
			if _goto_position != null:
				var pos_diff = _goto_position - _free_coin.global_position
				if pos_diff.length() > 64:
					pos_diff = pos_diff.normalized() * 64
				#_free_coin.move_and_collide(pos_diff)
				#_free_coin.move_and_slide(pos_diff/delta)
				_free_coin.move_and_slide(pos_diff/delta*0.25)
				_free_coin.visible = true
				if _free_coin.get_slide_count() > 0 and not _coin.playing:  # TODO: Maybe check velocity of collision.
					_coin.play()


func _update_moves():
	_moves_label.text = "MOVES\n" + str(_move_count)


func _reset_grid():
	_free_coin.visible = false
	for row in _coin_refs:
		for coin in row:
			coin.set_state_empty()
	for xy in INITIAL_COINS:
		_coin_refs[xy[0]][xy[1]].set_state_present()


func _fill_coin_grid():
	var r = _free_coin.get_radius()
	var f = sqrt(3)/2
	var x0 = -0.5*GRID_WIDTH * 2*r + r/2
	var y0 = -0.5*(GRID_HEIGHT-1) * 2*r*f #+ r*f/2
	for x in range(GRID_WIDTH):
		_coin_refs.append([])
		for y in range(GRID_HEIGHT):
			var coin = _coin_scene.instance()
			coin.position = Vector2(x0 + 2*r*x + r*(y % 2), y0 + 2*r*y*f)
			coin.set_state_empty()
			coin.connect("touched", self, "_coin_touched", [x, y, coin])
			coin.connect("released", self, "_coin_released", [x, y, coin])
			_coin_grid.add_child(coin)
			_coin_refs[-1].append(coin)


func _get_coin_neighbour_states(x, y):
	var result = []
	var dxs
	for dy in [-1, 0, 1]:
		if dy == 0:
			dxs = [-1, 1]
		elif y % 2 == 1:
			dxs = [0, 1]
		else:
			dxs = [-1, 0]
		for dx in dxs:
			var tx = x + dx
			var ty = y + dy
			if ty < 0 or ty >= GRID_HEIGHT or tx < 0 or tx >= GRID_WIDTH:
				result.append(0)
			else:
				result.append(int(_coin_refs[tx][ty].is_present()))
	return result


func _set_available_coins():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var coin = _coin_refs[x][y]
			var s = _get_coin_neighbour_states(x, y)
			coin.set_debug(str(x) + " " + str(y) + "\n" + str(s))
			var count = s[0] + s[1] + s[2] + s[3] + s[4] + s[5]
			if not coin.is_present() and _can_coin_slide(s) and count >= 2:
				coin.set_state_available()


func _set_all_unavailable():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var coin = _coin_refs[x][y]
			if not coin.is_present():
				coin.set_state_empty()


func _can_coin_slide(s):
	# Can slide if any 2 adjacent spots are open.
	var o = [1-s[0], 1-s[1], 1-s[3], 1-s[5], 1-s[4], 1-s[2], 1-s[0]]
	for i in range(6):
		if o[i] and o[i+1]:
			return true
	return false


func _coin_touched(x, y, coin):
	if _state == STATE.STILL and coin.is_present() and _can_coin_slide(_get_coin_neighbour_states(x, y)):
		coin.set_state_empty()
		_set_available_coins()
		_free_coin.global_position = coin.global_position
		_goto_position = null
		_state = STATE.DRAGGING


func _coin_released(x, y, coin):
	if _state == STATE.DRAGGING:
		var min_coin_xy = [x,y]
		var min_dist = INF
		for y in range(GRID_HEIGHT):
			for x in range(GRID_WIDTH):
				var c = _coin_refs[x][y]
				var dist = (c.global_position - _free_coin.global_position).length()
				if c.is_available() and dist <= _free_coin.get_radius()*2 and dist <= min_dist:
					min_coin_xy = [x,y]
					min_dist = dist
		_coin_refs[min_coin_xy[0]][min_coin_xy[1]].set_state_present()
		_set_all_unavailable()
		_free_coin.visible = false
		if min_dist != INF:
			_move_count += 1
			_update_moves()
		if _check_solved():
			_state = STATE.FINISHED
			Progress.set_progress(_header.title, true, true, true if _move_count == 3 else null)
			_header.update_status()
			_success.show(_move_count == 3)
		else:
			_state = STATE.STILL


func _check_solved():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var s = _get_coin_neighbour_states(x, y)
			if s[0] + s[1] + s[2] + s[3] + s[4] + s[5] == 6:
				return true
	return false


func _on_Footer_instructions_pressed():
	_instructions.visible = true
