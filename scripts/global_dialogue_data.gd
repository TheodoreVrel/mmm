extends Node

var dialogue_data = {}
var dialogue_data_array = []



func _ready() -> void:
	dialogue_data = load_dialogue_file("res://assets/text/dialogues.csv", "en")
	#dialogue_data_array = load_dialogue_csv("res://assets/text/Dialogues.csv")
	load_dialogue_csv("res://assets/text/dialogues.csv", "en")



func load_dialogue_file(path:String, language:String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	#var txt = file.get_as_text()
	
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

	var file = FileAccess.open(path, FileAccess.READ)
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
