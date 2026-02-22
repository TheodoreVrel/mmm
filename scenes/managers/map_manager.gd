extends Node2D

const DOTTED_LINE = preload("res://scenes/dotted_line.tscn")

var hovered_room : MinimapRoom
var room_zoom : MinimapRoom
var current_room : Room

var map_focusable : bool = true

var camera : Camera2D
var map

var all_rooms

signal opened_room(room)
signal left_room

func _ready():
	connect("opened_room", GameManager.on_entered_room)
	connect("left_room", GameManager.on_left_room)
	
	
func after_intro():
	all_rooms = map.rooms.get_children()
	set_room_shaders()
	ready_set_up()

func open_room():

		room_zoom = hovered_room
		#opened_room.emit(hovered_room.real_analog)
		#hovered_room.animation_player.play("zoom")
		camera.zoom_to_room(room_zoom)
		await get_tree().create_timer(1.0).timeout
		SceneTransitionManager.transition()
		await SceneTransitionManager.transition_fadeout_done
		#await get_tree().create_timer(1.0)
		current_room = room_zoom.real_analog
		current_room.visible = true
		map.visible = false
		opened_room.emit(current_room)

func leave_room(pass_time : bool = check_time_pass()):
	SceneTransitionManager.transition()
	await SceneTransitionManager.transition_fadeout_done
	current_room.visible = false
	map.visible = true
	camera.zoom_out()
	await get_tree().create_timer(1.0).timeout
	#await get_tree().create_timer(1.0)
	
	room_zoom = null
	current_room = null
	if pass_time: left_room.emit()

func check_time_pass():
	if current_room.room_id == "emo-room" and !SaveManager.flags["met"][GameManager.CHARACTERS["emo-witch"]]:
		return false
	if current_room.room_id == "hallway":
		return false
	return true

func _input(event):
	if event.is_action_pressed("next") and hovered_room and not event.is_echo():
		print(hovered_room)
		open_room()
	#elif event.is_action_released("ui_left"):
		


func map_layout_change():
	print("oooooooooooooooooooooooooooooooooooooooo")
	map.change_layout(TimeManager.TIME.find(TimeManager.current_time))
	await get_tree().create_timer(5.8).timeout
	add_path_lines()
	set_room_shaders()

func add_path_lines():
	for line in map.dotted_lines.get_children():
		line.queue_free()
	for room in all_rooms:
		if room.is_currently_accessible() :
			var new_line = DOTTED_LINE.instantiate()
			new_line.setup(map.hallway_minimap_room_pos, room.position)
			map.dotted_lines.add_child(new_line)
	

func set_room_shaders():
	for room in all_rooms:
		room.switch_shader()

func set_all_characters():
	for room in map.rooms_dict:
		map.rooms_dict[room].real_analog.characters_present.clear()
	
	set_character_in_room("housekeeper", "hallway")
	#set_character_in_room("cat", "hallway")
	match TimeManager.current_time:
		"morning":
			set_character_in_room("kitchen-witch", "kitchen")
			set_character_in_room("wolf-witch", "garden")
			set_character_in_room("time-witch", "clock-room")
			set_character_in_room("edgy-witch", "cave")
			set_character_in_room("monster-witch", "monster-room")
			set_character_in_room("emo-witch", "emo-room")
		"day":
			set_character_in_room("kitchen-witch", "none")
			set_character_in_room("wolf-witch", "kitchen")
			set_character_in_room("time-witch", "clock-room")
			set_character_in_room("edgy-witch", "cave")
			set_character_in_room("monster-witch", "monster-room")
			set_character_in_room("emo-witch", "emo-room")
		"night":
			set_character_in_room("kitchen-witch", "garden")
			set_character_in_room("wolf-witch", "none")
			set_character_in_room("time-witch", "clock-room")
			set_character_in_room("edgy-witch", "kitchen")
			set_character_in_room("monster-witch", "monster-room")
			set_character_in_room("emo-witch", "emo-room")
			
	
	

func set_character_in_room(character : String, room : String):
	#
	#if map.char_mini_dict[character].current_room != "":
		#map.rooms_dict[map.char_mini_dict[character].current_room].real_analog.characters_present.erase(character)
	if room != "none":
		map.rooms_dict[room].real_analog.characters_present.append(character)
	map.char_mini_dict[character].current_room = room


func character_set_up():
	set_all_characters()
	for character_mini in map.char_mini_dict :
		var new_room_id = map.char_mini_dict[character_mini].current_room
		print_debug("####\n####\n####\n", new_room_id, " | ", character_mini)
		
		if map.char_mini_dict[character_mini].current_room == "none" and map.char_mini_dict[character_mini].visible_on_map == true:
			map.char_mini_dict[character_mini].vanish()
		elif map.char_mini_dict[character_mini].visible_on_map == false and map.char_mini_dict[character_mini].current_room != "none" :
			map.char_mini_dict[character_mini].unvanish()
			await get_tree().create_timer(1).timeout
			map.char_mini_dict[character_mini].move_to_room(map.rooms_dict[new_room_id])
		elif map.char_mini_dict[character_mini].visible_on_map == true and map.char_mini_dict[character_mini].current_room != "none" : 
			map.char_mini_dict[character_mini].move_to_room(map.rooms_dict[new_room_id])
			

func ready_set_up():
	set_all_characters()
	for character_mini in map.char_mini_dict :
		var new_room_id = map.char_mini_dict[character_mini].current_room
		print_debug("####\n####\n####\n", new_room_id, " | ", character_mini)
		
		if new_room_id == "none":
			map.char_mini_dict[character_mini].vanish()
		else : map.char_mini_dict[character_mini].place_in_room(map.rooms_dict[new_room_id])
