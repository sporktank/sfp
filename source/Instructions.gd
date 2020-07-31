tool
extends Node2D


export(String, MULTILINE) var instruction_text = ""


onready var _text = $Text


func _ready():
	_text.text = instruction_text


func _on_Button_pressed():
	visible = false
