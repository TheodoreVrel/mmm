extends Node2D

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

@export var char_id : String

var current_room : String
var visible_on_map : bool = true

var MINI_CHARACTER_SPRITE = {
	#GameManager.CHARACTERS["cat"] : preload("res://assets/characters/mini/Circle.png"),
	GameManager.CHARACTERS["emo-witch"] : preload("res://assets/characters/mini/suzie.png"),
	GameManager.CHARACTERS["monster-witch"] : preload("res://assets/characters/mini/ink.png"),
	GameManager.CHARACTERS["edgy-witch"] : preload("res://assets/characters/mini/germaine.png"),
	GameManager.CHARACTERS["time-witch"] : preload("res://assets/characters/mini/mithra.png"),
	GameManager.CHARACTERS["kitchen-witch"] : preload("res://assets/characters/mini/delilah.png"),
	GameManager.CHARACTERS["housekeeper"] : preload("res://assets/characters/mini/moira.png"),
	#GameManager.CHARACTERS["dead-witch"] : preload(),
	GameManager.CHARACTERS["wolf-witch"] : preload("res://assets/characters/mini/temmie.png")
	}

func _ready():
	$Sprite2D.texture = MINI_CHARACTER_SPRITE[GameManager.CHARACTERS[char_id]]
	left = [true, false].pick_random()
	$Timer.wait_time += randf_range(0, 0.7776)

func move_to_room(room ):
	print (char_id, " visible : ", visible_on_map)
	$Timer.stop()
	#if !visible_on_map:
		#visible_on_map = true
		#animation_player.play_backwards("vanish")
		#await animation_player.animation_finished
	if global_position != room.npc_spots_positions[0].global_position:
		animation_player.play("start_move")
		await animation_player.animation_finished
		animation_player.play("movement")
		var t : Tween = get_tree().create_tween()
		t.tween_property(self, "position",room.npc_spots_positions[0].global_position, 1.2)
		await t.finished
		animation_player.stop()
		offset_idle()

func place_in_room(room):
	global_position = room.npc_spots_positions[0].global_position
	offset_idle()

func offset_idle():
	await get_tree().create_timer(randf_range(0.03, 1.09)).timeout
	$Timer.start()
	

func vanish():
	print(self, "vanishing")
	animation_player.play("vanish")
	visible_on_map = false

func unvanish():
	print(self, "vanishing")
	animation_player.play_backwards("vanish")
	await animation_player.animation_finished
	visible_on_map = true

var left : bool
func _on_timer_timeout():
	#print("r",rotation)
	global_rotation = deg_to_rad([3, 5, 7].pick_random())
	if left:
		rotation *= -1
		left = false
	else : left = true
