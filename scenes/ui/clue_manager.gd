extends Control

@onready var grid_container = $GridContainer
const CLUE = preload("res://scenes/ui/clue.tscn")
var clue_list : Dictionary

var in_dialogue : bool = false
signal presenting_item

@onready var clue_name = $NinePatchRect/MarginContainer/HBoxContainer/VBoxContainer/ClueName
@onready var clue_description = $NinePatchRect/MarginContainer/HBoxContainer/VBoxContainer/ClueDescription
@onready var clue_visual = $NinePatchRect/MarginContainer/HBoxContainer/ClueVisual
@onready var animation_player = $AnimationPlayer

func _ready():
	GameManager.clues_manager = self
	presenting_item.connect(GameManager.on_item_presented)
	MapManager.left_room.connect(show_back)
	clue_list = parse_clue_list("res://assets/text/clues.csv", "en")
	print(clue_list)
	update_clue_list()

func parse_clue_list(path:String, language:String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue CSV")
		return {}

	var lines = []
	while not file.eof_reached():
		var raw_line = file.get_csv_line()
		lines.append(raw_line)
	if lines.size() < 2:
		return {}

	var header = lines[0]

	var id_i = header.find("id")
	var text_i = header.find(language)
	
	var clue = {}
	for r in range(1, lines.size()):
		var row = lines[r]
		var line_id = row[id_i]

		if line_id == "":
			continue
		
		clue[line_id] = row[text_i]

	return clue

func update_clue_list():
	for clue in grid_container.get_children():
		clue.queue_free()
	for clue in SaveManager.clues:
		print(clue, " ", SaveManager.flags.found_clue[clue])
		if SaveManager.flags.found_clue[clue] == true:
			print("you have ",clue)
			add_clue(clue)

func add_clue(clue : String):
	var new_clue = CLUE.instantiate()
	
	var info : String = clue_list[clue]
	var str_array = info.rsplit(":", true, 1)
	new_clue.clue_id = clue
	new_clue.clue_name = str_array[0]
	new_clue.clue_description = str_array[1]
	new_clue.texture = load("res://assets/hints/" + clue +".png")
	
	new_clue.clicked_clue.connect(read_clue)
	
	grid_container.add_child(new_clue)


func read_clue(clue):
	if !in_dialogue:
		clue_name.text = clue.clue_name
		clue_description.text = clue.clue_description
		clue_visual.texture = clue.texture
		animation_player.play("open_desc")
	else:
		presenting_item.emit(clue)
		print_debug("presenting ", clue.clue_id)


func _on_clear_desc_button_button_up():
	animation_player.play_backwards("open_desc")


func _on_open_button_button_up():
	grid_container.visible = !grid_container.visible

func show_clues_in_dialogue():
	grid_container.visible = true
	$OpenButton.visible = false
	$NinePatchRect.visible = false
	in_dialogue = true

func hide_for_dialogue():
	grid_container.visible = false
	$OpenButton.visible = false
	$NinePatchRect.visible = false
	in_dialogue = true
	
func show_back():
	grid_container.visible = false
	$OpenButton.visible = true
	$NinePatchRect.visible = false
	in_dialogue = false




func _on_button_mouse_entered():
	show_shader()


func _on_button_mouse_exited():
	show_shader(false)

func show_shader(s_is_visible : bool = true):
	$OpenButton/TextureRect.material.set_shader_parameter("show", s_is_visible)
