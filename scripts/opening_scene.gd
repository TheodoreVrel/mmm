extends Node2D

@onready var animation_player_bonus: AnimationPlayer = $AnimationPlayerBonus

var dialogues = 0
func on_free():
	GameManager.intro_scene = false

func _ready() -> void:
	#$CanvasLayer/DialogueUi.dialogue_end.connect(intro_end)
	print("Exists:", ResourceLoader.exists("res://assets/text/Dialogues - dialogue.csv"))
	#await get_tree().create_timer(1.11).timeout
	
	$CanvasLayer/DialogueUi.start_dialogue("cat_[neutral]____openingscene_%°c@#")
	var file = FileAccess.open("res://assets/text/Dialogues - Feuille 3.csv", FileAccess.READ)
	if not file:
		push_error("CSV failed to open__ " )
		return
	var text = file.get_as_text()
	print(text)

func intro_end():
	#dialogues += 1
	#if dialogues >= 2:
		SceneTransitionManager.intro_scene_end()
		on_free()
		queue_free()

func intro_part2():
	$CanvasLayer/DialogueUi.visible = true
	$CanvasLayer/DialogueUi.start_dialogue("kitchen-witch_[happy]___openingscene-8__%°@#")

func intro_part3():
	$CanvasLayer/DialogueUi.visible = true
	$CanvasLayer/DialogueUi.start_dialogue("cat_[neutral]___openingscene-31__%°c@#")
	
