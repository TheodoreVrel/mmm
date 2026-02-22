extends Node2D
class_name MinimapRoom

@export var real_analog : Room
@export var accessible_morning : bool = true
@export var accessible_day : bool = true
@export var accessible_night : bool = true
#@onready var animation_player = $AnimationPlayer
const GRAYSCALE = preload("res://shaders/grayscale.gdshader")
const HIGHLIGHT_1 = preload("res://shaders/highlight1.gdshader")
@onready var npc_spots_positions = $npc_spots.get_children()



func _ready():
	if real_analog != null:
		real_analog.minimap_analog = self

func is_currently_accessible() -> bool:
	if GameManager.intro_scene:
		return true
	if real_analog.room_id == "cave" and !SaveManager.flags["met"][GameManager.CHARACTERS["edgy-witch"]]:
		return false
	if real_analog.room_id == "victim-room" and !SaveManager.flags["found_clue"]["vickyskey"]:
		return false
	if TimeManager.current_time == "morning":
		return accessible_morning
	elif TimeManager.current_time == "day":
		return accessible_day
	elif TimeManager.current_time == "night":
		return accessible_night
	return false

func _on_area_2d_mouse_entered():
	if is_currently_accessible() and MapManager.map_focusable:
		MapManager.hovered_room = self
		show_shader()

func _on_area_2d_mouse_exited():
	if is_currently_accessible():
		if MapManager.hovered_room == self:
			MapManager.hovered_room = null
		show_shader(false)

func show_shader(s_is_visible : bool = true):
	$Sprite2D.material.set_shader_parameter("show", s_is_visible)

func switch_shader():
	if is_currently_accessible():
		$Sprite2D.material.shader = HIGHLIGHT_1
	else : $Sprite2D.material.shader = GRAYSCALE
