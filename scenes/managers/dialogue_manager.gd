extends Control

@export var force_include_csv: Resource

const CHOICE_BOX = preload("res://scenes/ui/choice_box.tscn")
@onready var choice_box_container = $ChoiceBoxContainer
@onready var text_label = $NinePatchRect/TextLabel
@onready var speaker_label = $SpeakerLabel
@onready var npc = $NPC
@onready var cat = $Cat
const rpath = "res://assets/text/dialogues.csv"

var dialogue_data = {}
var dialogue_data_array = []
var current_line_id = ""
var waiting_for_next = false

signal request_open_clues
signal dialogue_start
signal dialogue_end
signal given_new_clue(clue)

func _ready():
	#print("Exists (ResourceLoader):", ResourceLoader.exists("res://assets/text/dialogues.csv"))
	#print("Exists (FileAccess):", FileAccess.file_exists("res://assets/text/dialogues.csv"))
	
	#await get_tree().create_timer(0.11).timeout
	GameManager.dialogue_manager = self
	request_open_clues.connect(GameManager.on_clue_open_request)
	dialogue_start.connect(GameManager.on_dialogue_start)
	#dialogue_end.connect(GameManager.on_dialogue_end)
	given_new_clue.connect(GameManager.unlock_clue)
	#print(load_dialogue_file("res://assets/text/dialogues_v3.csv", "en"))
	#dialogue_data = load_dialogue_file("res://assets/text/dialogues.csv", "en")
	##dialogue_data_array = load_dialogue_csv("res://assets/text/Dialogues.csv")
	#load_dialogue_csv("res://assets/text/dialogues.csv", "en")
	#print(get_start_id("time-witch", "clock", "day", ["default"]))
	#start_dialogue(get_start_id("edgy-witch", "kitchen", "night", ["default"]))
	#start_dialogue(get_start_id("housekeeper", "kitchen", "night", ["default"]))
	#print_debug(get_item_given_from_id("edgy-witch_[neutralddd]_kitchen_night_q1-answer__%°@turn-vanish-wiggle#"))
	#print_debug(GameManager.CHARACTER_SPRITE[GameManager.CHARACTERS["edgy-witch"]]["sad"])
	if dialogue_data == {}:
		dialogue_data = GlobalDialogueData.dialogue_data
		dialogue_data_array = GlobalDialogueData.dialogue_data_array

#func get_line(character : String, time : String, room : String, start_condition : String):
	#var final_id : String 
	#final_id = character + "_" + time + "_" + room + "_" + start_condition

func start_dialogue(id):
	current_line_id = id
	visible = true
	$NinePatchRect.visible = true
	$SpeakerLabel.visible = true
	$ChoiceBoxContainer.visible = true
	$AnimationPlayer.play("start_dialogue")
	dialogue_start.emit()
	show_line()

func load_dialogue_file(path:String, language:String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue CSV")
		print("FAILED TO LOAD CSV")
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

	var choice_i = []
	var next_i = []

	for n in range(1, 7):
		choice_i.append(header.find("choice_%d" % n))
		next_i.append(header.find("next_line_%d" % n))

	var dialogue = {}

	for r in range(1, lines.size()):
		var row = lines[r]
		var line_id = row[id_i]

		if line_id == "":
			continue

		var entry = {
			"text": row[text_i],
			"choices": [],
			"next": []
		}

		# Collect choices
		for n in range(6):
			if choice_i[n] == -1:
				continue

			var choice = row[choice_i[n]]
			var next_line = row[next_i[n]]

			if choice != "":
				entry["choices"].append(choice)
				entry["next"].append(next_line)

		# Handle no-choice auto progression
		if entry["choices"].is_empty():
			var next_default = row[next_i[0]]
			if next_default != "":
				entry["next"].append(next_default)

		dialogue[line_id] = entry

	return dialogue

var start_lines = []
func load_dialogue_csv(path:String, language:String) -> void:
	dialogue_data.clear()
	start_lines.clear()

	var file = FileAccess.open("res://assets/text/dialogues.csv", FileAccess.READ)
	print("f ", file)
	print("rrr", FileAccess.file_exists("res://assets/text/dialogues.csv"))
	if file == null:
		push_error("Failed to open dialogue CSV")
		return

	var header = file.get_csv_line()

	var id_i = header.find("id")
	var character_i = header.find("character_id")
	var room_i = header.find("room_id")
	var time_i = header.find("time")
	var condition_i = header.find("start_condition")
	var variant_i = header.find("variant")
	var text_i = header.find(language)

	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.is_empty():
			continue

		var id = row[id_i].strip_edges()
		if id == "":
			continue

		var character = row[character_i].strip_edges()
		var room = row[room_i].strip_edges()
		var time = row[time_i].strip_edges()
		var condition = row[condition_i].strip_edges()
		var variant = row[variant_i].strip_edges()
		var text = row[text_i].strip_edges()

		# ---- Build full dialogue entry (used by your dialogue runner) ----
		var full_entry = {
			"text": text,
			"choices": [],
			"next": []
		}

		# Choices + next lines
		for n in range(1, 7):
			var choice_i = header.find("choice_%d" % n)
			var next_i = header.find("next_line_%d" % n)

			if choice_i == -1:
				continue

			var choice = row[choice_i].strip_edges()
			var next_line = row[next_i].strip_edges()

			if choice != "":
				full_entry.choices.append(choice)
				full_entry.next.append(next_line)

		# Default next line (if no choices)
		if full_entry.choices.is_empty():
			var default_next_i = header.find("next_line_1")
			if default_next_i != -1:
				var default_next = row[default_next_i].strip_edges()
				if default_next != "":
					full_entry.next.append(default_next)

		dialogue_data[id] = full_entry

		# ---- Store startable line info ----
		# We only need metadata here
		var start_entry = {
			"id": id,
			"character": character,
			"room": room,
			"time": time,
			"condition": condition,
			"variant": variant
		}

		start_lines.append(start_entry)

func get_start_id(character:String, room:String, time:String, active_conditions:Array) -> String:
	var best_id = ""
	var best_score = -1
	var condition = active_conditions[0]
	var shownitem_other_id : String = ""
	var showing : bool = false
	
	for entry in start_lines:

		if entry.character == character:
			if !SaveManager.flags["met"][GameManager.CHARACTERS[character]]:
				if character == "edgy-witch" and room == "kitchen" and time == "night":
					return "edgy-witch_[neutral]_kitchen_night__default_%°@flipped#"
				elif entry.condition.substr(0,5) == "intro":
					print_debug("Character intro = ", entry)
					SaveManager.flags["met"][GameManager.CHARACTERS[character]] = true
					return entry.id
		else : continue
		if condition != "":
			#print_debug(entry.condition.substr(0,9))
			#print("aaabbbccc".substr(0, 5))
			
			if condition.substr(0,9) == "shownitem":
				showing = true
				if condition == entry.condition:
					print_debug("This should work. item = ", entry)
					return entry.id
				elif entry.condition == "shownitem-other":
					shownitem_other_id = entry.id
					print("other - ", shownitem_other_id)
					continue
			if not active_conditions.has(entry.condition):
				continue
		if entry.room != "" and entry.room != room:
			continue

		if entry.time != "" and entry.time != time:
			continue

		

		var score = 0
		if entry.room != "": score += 1
		if entry.time != "": score += 1
		if entry.condition != "": score += 1

		if score > best_score:
			best_score = score
			best_id = entry.id
			
	if shownitem_other_id != "" and showing:
		return shownitem_other_id
	return best_id


func get_speaker_from_id(id:String) -> String:
	var speaker = id.split("_")[0]
	return GameManager.CHARACTERS[speaker]

func get_sprite_from_id(id: String) -> Texture:
	var speaker = id.split("_")[0]
	if get_cat_speaking_from_id(id) : speaker = "cat"
	var emotion = id.substr(id.find("[")+1, id.find("]")-id.find("[")-1)
	
	#print_debug("witch sprite : " , GameManager.CHARACTERS[speaker])
	
	return GameManager.CHARACTER_SPRITE[GameManager.CHARACTERS[speaker]][emotion]

func get_cat_speaking_from_id(id: String) -> bool:
	var a = id.find("°")
	return id[a+1] == "c"

func get_effects_from_id(id: String) -> Array:
	var a = id.substr(id.find("@")+1, id.find("#")-id.find("@")-1)
	return a.rsplit("-")

func get_item_given_from_id(id: String) -> String:
	return id.substr(id.find("#")+1)

func show_line():
	#print("Requested ID:", current_line_id)
	#print("All keys:", dialogue_data.keys())
	
	print_debug("_________________________", current_line_id)
	var line = dialogue_data[current_line_id]
	
	if (current_line_id == "[clues]"):
		$NinePatchRect.hide()
		$SpeakerLabel.hide()
		$ChoiceBoxContainer.hide()
		clue_showing()
		return
	if current_line_id == "[transport]":
		$"../../AnimationPlayerBonus".play("transport")
		return
	elif current_line_id == "[scene-end]":
		$"../..".intro_end()
		return
	elif current_line_id == "[mansion-shift]":
		$"../../AnimationPlayerBonus".play("show_shift")
		return
	
	# Speaker
	speaker_label.text = get_speaker_from_id(current_line_id)

	# Text
	text_label.text = line.text
	
	
	
	npc.flip_h = true
	npc.visible = !get_cat_speaking_from_id(current_line_id)
	cat.visible = get_cat_speaking_from_id(current_line_id)
	if get_cat_speaking_from_id(current_line_id):
		cat.texture = get_sprite_from_id(current_line_id)
	else : npc.texture = get_sprite_from_id(current_line_id)
	
	var new_clue_found : String = get_item_given_from_id(current_line_id)
	print("___________ è ", new_clue_found)
	if !new_clue_found == "":
		given_new_clue.emit(new_clue_found)
	
	trigger_effects(get_effects_from_id(current_line_id))
	
	# Clear old choices
	for child in choice_box_container.get_children():
		child.queue_free()

	waiting_for_next = false
	print("eeeeeeeeeeeeeeee  ",line.next)
	if line.choices.is_empty():
		#if line.next.is_empty():
			waiting_for_next = true
			#end_dialogue()
		#else:
			#waiting_for_next = true
	else:
		create_choice_buttons(line)

func _input(event):
	if event.is_action_pressed("next") and waiting_for_next and not event.is_echo() and $Timer.is_stopped():
		
		var line = dialogue_data[current_line_id]

		if not line.next.is_empty() :
			current_line_id = line.next[0]
			show_line()
		else:
			end_dialogue()
		$Timer.start()


func create_choice_buttons(line):
	for i in range(line.choices.size()):
		var btn = CHOICE_BOX.instantiate()
		btn.text = line.choices[i]

		btn.pressed.connect(func():
				current_line_id = line.next[i]
				if current_line_id != "":
					show_line()
					else : end_dialogue()
			
		)

		choice_box_container.add_child(btn)


func end_dialogue():
	hide() # or emit signal
	dialogue_end.emit()


func clue_showing():
	#print("èèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèèè")
	request_open_clues.emit()


#func default_clue_answer(clue_id):
	#if 

func trigger_effects(effects : Array):
	print("çççççççççççççççççççççççççççççççççççççççççççççççççç")
	if effects == []:
		return
	for effect in effects:
		if effect == "turn":
			npc.turn()
		if effect == "flipped":
			npc.flip_sprite()
		if effect == "vanish":
			npc.vanish()
		if effect == "mansion-shift":
			TimeManager.time_pass()
			
