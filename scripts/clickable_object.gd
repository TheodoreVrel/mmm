extends Area2D
class_name ClickableObject

@export var object_id : String
@onready var sprite = $Sprite2D

const HIGHLIGHT_SHADER = preload("res://shaders/highlight1.gdshader")
var shader_material : ShaderMaterial


func _ready():
	print("222222222222222222222")
	
	sprite.material = ShaderMaterial.new()
	sprite.material.shader = HIGHLIGHT_SHADER
	shader_material = sprite.material
	shader_material.shader.setup_local_to_scene()
	#$Sprite2D.shader

func _on_mouse_entered():
	show_shader()
	ClickableObjectManager.current_object = self
	print("hovered")


func _on_mouse_exited():
	if ClickableObjectManager.current_object == self:
		ClickableObjectManager.current_object = null
	show_shader(false)


func show_shader(s_is_visible : bool = true):
	shader_material.set_shader_parameter("show", s_is_visible)
