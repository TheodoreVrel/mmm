extends TextureRect

var clue_id : String
var clue_name : String 
var clue_description : String

signal clicked_clue

func _ready():
	material.shader.setup_local_to_scene()

func _on_button_button_up():
	clicked_clue.emit(self)


func _on_button_mouse_entered():
	show_shader()


func _on_button_mouse_exited():
	show_shader(false)

func show_shader(s_is_visible : bool = true):
	material.set_shader_parameter("show", s_is_visible)
