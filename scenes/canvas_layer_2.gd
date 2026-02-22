extends CanvasLayer

@onready var open_button : Button = $OpenButton
var rooms

func _ready():
	if !GameManager.intro_scene:
		open_button.button_up.connect(MapManager.leave_room)
	
		rooms = [$CaveRoom,$ClockRoom, $EmoRoom, $GardenRoom, $Hallway, $KitchenRoom, $MonsterRoom, $VictimRoom]
		
		for room : Room in rooms:
			room.visibility_changed.connect(show_return_button)
		show_return_button()

func show_return_button():
	for room : Room in rooms:
		if room.visible == true:
			open_button.visible = true
			return
	open_button.visible = false


func _on_button_mouse_entered():
	show_shader()


func _on_button_mouse_exited():
	show_shader(false)

func show_shader(s_is_visible : bool = true):
	$OpenButton/TextureRect.material.set_shader_parameter("show", s_is_visible)
