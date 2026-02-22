extends Node2D


var current_object : ClickableObject
var object_handled : bool = false

signal interacted(object)

func _ready():
	interacted.connect(GameManager.on_thing_clicked)

func interact():
	print("interacted")
	object_handled = true
	interacted.emit(current_object)

func _input(event):
	if current_object and event.is_action_pressed("click") and not event.is_echo() and !object_handled:
		
		interact()
