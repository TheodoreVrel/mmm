extends AudioStreamPlayer

@export var musics : Array[AudioStream]

func _ready():
	TimeManager.time_change.connect(play_music)
	play_music(0)

func play_music(music_num : int):
	var pos = get_playback_position()
	stream = musics[music_num]
	play(pos)
