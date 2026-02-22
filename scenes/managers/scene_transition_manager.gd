extends CanvasLayer
@onready var animation_player : AnimationPlayer = $AnimationPlayer

signal transition_fadeout_done

func transition():
	animation_player.play("transition")
	await animation_player.animation_finished
	transition_fadeout_done.emit()
	animation_player.play_backwards("transition")
	await animation_player.animation_finished

func intro_scene_end():
	transition()
	await transition_fadeout_done
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
	await get_tree().scene_changed
	MapManager.after_intro()
