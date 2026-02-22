extends Control
class_name Room

@export var room_id : String
@export var room_textures : Array[Texture]
#@onready var room_text = $RoomTexture
@export var minimap_analog : MinimapRoom

@export var pickable_objects : Array[ClickableObject]
@export var characters_present : Array[String]
#var accessible : bool = true

func _ready():
	#room_text = room_texture
	if minimap_analog != null:
		minimap_analog.real_analog = self
	if room_textures.size() > 1:
		TimeManager.time_change.connect(texture_change_for_time)

func _on_visibility_changed():
	pass # Replace with function body.

func texture_change_for_time(time):
	
	$RoomTexture.texture = room_textures[time]
