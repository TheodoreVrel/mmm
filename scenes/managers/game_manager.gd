extends Node2D

var dialogue_manager
var clues_manager
var map



var current_room

var camera : Camera2D

const CHARACTERS : Dictionary = {
	"cat" : "S. Holmes", 
	"emo-witch" : "Suzie",
	"monster-witch" : "Mrs. Ink",
	"housekeeper" : "Moira",
	"edgy-witch" : "Germaine",
	"time-witch" : "Mithra",
	"kitchen-witch" : "Delilah",
	"dead-witch" : "Vicky",
	"wolf-witch" : "Temmie",
	"door" : "???"
}

@onready var CHARACTER_SPRITE : Dictionary = {
	GameManager.CHARACTERS["cat"] : {
		"neutral" : preload("res://assets/characters/cat/cat_0000.png"),
		"displeased" : preload("res://assets/characters/cat/cat_0003.png"),
		"worried" : preload("res://assets/characters/cat/cat_0003.png"),
		"sad" : preload("res://assets/characters/cat/cat_0000.png"),
		"angry" : preload("res://assets/characters/cat/cat_0000.png"),
		"happy" : preload("res://assets/characters/cat/cat_0000.png"),
	},
	GameManager.CHARACTERS["emo-witch"] : {
		"neutral" : preload("res://assets/characters/emo_witch/IMG_0055.png"),
		"displeased" : preload("res://assets/characters/emo_witch/IMG_0056.png"),
		"worried" : preload("res://assets/characters/emo_witch/IMG_0058.png"),
		"sad" : preload("res://assets/characters/emo_witch/IMG_0060.png"),
		"angry" : preload("res://assets/characters/emo_witch/IMG_0059.png"),
		#"happy" : preload(),
	},
	GameManager.CHARACTERS["monster-witch"] : {
		"neutral" : preload("res://assets/characters/monster_witch/IMG_0049.png"),
		"displeased" : preload("res://assets/characters/monster_witch/IMG_0051.png"),
		"sad" : preload("res://assets/characters/monster_witch/IMG_0054.png"),
		"angry" : preload("res://assets/characters/monster_witch/IMG_0052.png"),
		"happy" : preload("res://assets/characters/monster_witch/IMG_0050.png"),
	},
	GameManager.CHARACTERS["edgy-witch"] : {
		"neutral" : preload("res://assets/characters/edgy_witch/IMG_0022.png"),
		"displeased" : preload("res://assets/characters/edgy_witch/IMG_0023.png"),
		"worried" : preload("res://assets/characters/edgy_witch/IMG_0024.png"),
		"sad" : preload("res://assets/characters/edgy_witch/IMG_0025.png"),
		"special" : preload("res://assets/characters/edgy_witch/IMG_0026.png"),
		"angry" : preload("res://assets/characters/edgy_witch/IMG_0027.png"),
		"happy" : preload("res://assets/characters/edgy_witch/IMG_0029.png"),
	},
	GameManager.CHARACTERS["time-witch"] : {
		"neutral" : preload("res://assets/characters/time_witch/IMG_0020.png"),
		"displeased" : preload("res://assets/characters/time_witch/IMG_0019.png"),
		"worried" : preload("res://assets/characters/time_witch/IMG_0016.png"),
		"sad" : preload("res://assets/characters/time_witch/IMG_0017.png"),
		"angry" : preload("res://assets/characters/time_witch/IMG_0021.png"),
		"happy" : preload("res://assets/characters/time_witch/IMG_0018.png"),
	},
	GameManager.CHARACTERS["kitchen-witch"] : {
		"neutral" : preload("res://assets/characters/kitchen_witch/IMG_0035.png"),
		"displeased" : preload("res://assets/characters/kitchen_witch/IMG_0034.png"),
		"worried" : preload("res://assets/characters/kitchen_witch/IMG_0036.png"),
		"sad" : preload("res://assets/characters/kitchen_witch/IMG_0037.png"),
		"angry" : preload("res://assets/characters/kitchen_witch/IMG_0033.png"),
		"happy" : preload("res://assets/characters/kitchen_witch/IMG_0032.png"),
	},
	GameManager.CHARACTERS["housekeeper"] : {
		"neutral" : preload("res://assets/characters/housekeeper/IMG_0064.png"),
		"sad" : preload("res://assets/characters/housekeeper/IMG_0065.png"),
		"happy" : preload("res://assets/characters/housekeeper/IMG_0063.png"),
	},
	GameManager.CHARACTERS["wolf-witch"] : {
		"neutral" : preload("res://assets/characters/wolf_witch/IMG_0010.png"),
		"displeased" : preload("res://assets/characters/wolf_witch/IMG_0012.png"),
		"worried" : preload("res://assets/characters/wolf_witch/IMG_0014.png"),
		"sad" : preload("res://assets/characters/wolf_witch/IMG_0013.png"),
		"angry" : preload("res://assets/characters/wolf_witch/IMG_0015.png"),
		"happy" : preload("res://assets/characters/wolf_witch/IMG_0011.png"),
	},
	GameManager.CHARACTERS["door"] : {
		"neutral" : preload("res://assets/characters/98397359-cartoon-wooden-colorful-door-3555111181.jpg")
	}
}

const CONDITIONS : Array[String] = ["default", "intro", "shownitem-other"]

var intro_scene : bool = true
var victim_room_opened : bool = false

func on_entered_room(room : Room):
	print("entered room : ",room)
	current_room = room
	
	if room.room_id == "victim-room" and !victim_room_opened:
			victim_room_opened = true
			dialogue_manager.start_dialogue("cat_[neutral]____vickysroom_%°c@#")
	elif !room.characters_present.is_empty():
		#print("????")
		#print(room.characters_present[0], room.room_id, TimeManager.current_time, ["default"])
		print("#############################")
		if room.characters_present[0] == "emo-witch" and !SaveManager.flags["met"][GameManager.CHARACTERS["emo-witch"]]:
			
			dialogue_manager.start_dialogue("door_[neutral]____default_%°@#")
		elif room.characters_present[0] == "kitchen-witch" and !SaveManager.flags["met"][GameManager.CHARACTERS["kitchen-witch"]] and TimeManager.current_time == "night":
			dialogue_manager.start_dialogue("kitchen-witch_[sad]_garden___intro_%°@#met-kitchen-witch")

		else:
			dialogue_manager.start_dialogue(
				dialogue_manager.get_start_id(
					room.characters_present[0], room.room_id, TimeManager.current_time, get_situation()))

func get_situation() -> Array[String]:
	var conditions : Array[String] = []
	
	if conditions.is_empty():
		conditions.append(CONDITIONS[0])
	return conditions


func on_left_room(time_pass : bool = true):
	if time_pass :
		TimeManager.time_pass()
		await get_tree().create_timer(0.4).timeout
		MapManager.map_layout_change()

func on_dialogue_start():
	if !GameManager.intro_scene:
		clues_manager.hide_for_dialogue()
#func on_dialogue_end():
	#clues_manager.show_after_dialogue()


func on_clue_open_request():
	clues_manager.show_clues_in_dialogue()

func on_item_presented(item):
	var n_item = item.clue_id
	if n_item == "tod-afternight" or n_item == "tod-beforemorning":
		n_item = "tod-any"
	if current_room.characters_present[0] == "emo-witch" and !SaveManager.flags["met"][GameManager.CHARACTERS["emo-witch"]]:
		#print_debug("ggggllglm,mlnip ----- ", str("shownitem-" + item.clue_id), dialogue_manager.get_start_id(
			#current_room.characters_present[0], current_room.room_id, TimeManager.current_time, [str("shownitem-" + item.clue_id)]))
	
		dialogue_manager.start_dialogue(
			dialogue_manager.get_start_id(
				"door", current_room.room_id, TimeManager.current_time, [str("shownitem-" + n_item)]))
	
	else:
		dialogue_manager.start_dialogue(
			dialogue_manager.get_start_id(
				current_room.characters_present[0], current_room.room_id, TimeManager.current_time, [str("shownitem-" + n_item)]))


func unlock_clue(item : String):
	if !item.begins_with("met"):
		print(item)
		print("  #########################################  ", SaveManager.flags["found_clue"][item])
		SaveManager.flags["found_clue"][item] = true
		if item == "tod-afternight" or item == "tod-beforemorning":
			SaveManager.flags["found_clue"]["tod-none"] = false
			if SaveManager.flags["found_clue"]["tod-beforemorning"] == true and SaveManager.flags["found_clue"]["tod-afternight"] == true :
				SaveManager.flags["found_clue"]["tod-beforemorning"] = false
				SaveManager.flags["found_clue"]["tod-afternight"] = false
				SaveManager.flags["found_clue"]["tod-final"] = true
		if item == "alarmclock-fixed":
			SaveManager.flags["found_clue"]["alarmclock"] = false
		clues_manager.update_clue_list()
		
		clues_manager ##Here to add an effect to notify new clue


func on_thing_clicked(item : ClickableObject):
	#print(item.item_id)
	if !item:
		return
	elif item.object_id == "shed":
		if !SaveManager.flags["found_clue"]["secretknock"]:
			dialogue_manager.start_dialogue("cat_[neutral]____click-shed_%°c@#")
		else : 
			dialogue_manager.start_dialogue("edgy-witch_[angry]____intro_%°@#met-edgy-witch")
			item.queue_free()
			SaveManager.flags["met"][GameManager.CHARACTERS["edgy-witch"]] = true
	elif item.object_id == "fungalcake":
		dialogue_manager.start_dialogue("emo-witch_[displeased]____founditem-fungalcake_%°@#")
		unlock_clue("fungalcake")
	elif item.object_id == "tornphoto":
		dialogue_manager.start_dialogue("cat_[neutral]____founditem-tornphoto_%°c@#")
		unlock_clue("tornphoto")
	elif item.object_id == "alarmclock":
		dialogue_manager.start_dialogue("cat_[neutral]____founditem-alarmclock_%°c@#")
		unlock_clue("alarmclock")
	elif item.object_id == "cat_bed":
		dialogue_manager.start_dialogue("cat_[neutral]____nap_%°c@#")
		await dialogue_manager.dialogue_end
		await get_tree().create_timer(0.3).timeout
		MapManager.leave_room(true)
	
	await dialogue_manager.dialogue_end
	await get_tree().create_timer(0.8).timeout
	ClickableObjectManager.object_handled = false
