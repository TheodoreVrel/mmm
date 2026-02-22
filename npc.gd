extends Sprite2D

@onready var animation_player = $AnimationPlayer

#
#
#var current_character : String = ""
#
#func change_character(new_character : String, emotion = "neutral"):
	#if new_character in GameManager.CHARACTERS:
		#var char : Dictionary = GameManager.CHARACTER_SPRITE.get(GameManager.CHARACTERS[new_character])
		#$Sprite2D.texture = char.get(emotion)
		#current_character = new_character

func flip_sprite():
	scale.x *= 1

func turn():
	var tw : Tween = get_tree().create_tween()
	var scx = scale.x
	tw.tween_property(self, "scale", Vector2(scx, scale.y), 0.5)

func vanish():
	animation_player.play("vanish")
