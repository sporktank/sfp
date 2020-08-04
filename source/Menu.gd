extends Control


onready var _puzzles = $Middle/Puzzles.get_children()
onready var _splash = $Splash


func _ready():
	get_tree().set_quit_on_go_back(true)
	_splash.visible = Progress.show_splash
	Progress.show_splash = false
	for p in _puzzles:
		p.set_status(Progress.get_progress(p.puzzle_name, 1), Progress.get_progress(p.puzzle_name, 2))


func _on_SixCoins_pressed():
	get_tree().change_scene("res://source/SixCoins.tscn")


func _on_TaxCity_pressed():
	get_tree().change_scene("res://source/TaxCity.tscn")


func _on_Princess_pressed():
	get_tree().change_scene("res://source/Princess.tscn")


func _on_SecretReset_pressed():
	Progress.reset()
	get_tree().reload_current_scene()


func _on_Rate_pressed():
	if OS.get_name() == "iOS":
		OS.shell_open("https://apps.apple.com/app/id1525669188")
	else:
		# Assume / link to Android if not on iOS.
		OS.shell_open("http://play.google.com/store/apps/details?id=com.sporktank.sfp")
