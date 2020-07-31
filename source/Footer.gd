extends Control


signal instructions_pressed


export(String) var credits_link = ""


onready var _click = $Click


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_Back_pressed()
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_Back_pressed()


func _on_Restart_pressed():
	_click.play()
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().reload_current_scene()


func _on_Back_pressed():
	_click.play()
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().change_scene("res://source/Menu.tscn")


func _on_Credits_pressed():
	_click.play()
	yield(get_tree().create_timer(0.05), "timeout")
	OS.shell_open(credits_link)


func _on_Instructions_pressed():
	_click.play()
	emit_signal("instructions_pressed")
