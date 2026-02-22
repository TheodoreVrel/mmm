extends Camera2D

func _ready():
	GameManager.camera = self
	MapManager.camera = self


func zoom_to_room(room : MinimapRoom):
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "position", room.global_position, 0.7)
	tw.parallel().tween_property(self, "zoom", Vector2(5, 5), 1.1)
	await tw.finished
	await get_tree().create_timer(0.4).timeout
	#position = Vector2.ZERO
	#zoom = Vector2.ONE

func zoom_out():
	var tw : Tween = get_tree().create_tween()
	tw.tween_property(self, "position", Vector2.ZERO, 0.7)
	tw.parallel().tween_property(self, "zoom", Vector2(0.88, 0.88), 1.1)
	await tw.finished
	await get_tree().create_timer(0.4).timeout
