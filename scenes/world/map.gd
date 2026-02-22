extends Node2D

@onready var map_moving_animator = $MapMovingAnimator
#@onready var player_animation_player = $Rooms/BaseRoom/PlayerMarker/AnimationPlayer
@onready var rooms = $Rooms
@onready var dotted_lines = $CastleVisuals/DottedLines
@onready var hallway_minimap_room_pos = $Rooms/HallwayMinimapRoom.position

#var current_layout : int = 0

const castle_background : Dictionary = {
	"castle_morning" : preload("res://assets/castle/castle_whole_0000.png"),
	"castle_day" : preload("res://assets/castle/castle_whole_0001.png"),
	"castle_night" : preload("res://assets/castle/castle_whole_0002.png")}

@onready var rooms_dict : Dictionary = {
	"cave" : $Rooms/CaveMinimapRoom,
	"clock-room" : $Rooms/ClockMinimapRoom, 
	"emo-room" : $Rooms/EmoMinimapRoom, 
	"garden" :$Rooms/GardenMinimapRoom, 
	"hallway" :$Rooms/HallwayMinimapRoom, 
	"kitchen" :$Rooms/KitchenMinimapRoom, 
	"monster-room" :$Rooms/MonsterMinimapRoom, 
	"victim-room" :$Rooms/VictimMinimapRoom
}
@onready var char_mini_dict : Dictionary = {
	#"cat" : $NPCMarkers/NPCMapIcon,
	"emo-witch" : $NPCMarkers/NPCMapIcon4,
	"monster-witch" : $NPCMarkers/NPCMapIcon6,
	"edgy-witch" : $NPCMarkers/NPCMapIcon3,
	"time-witch" : $NPCMarkers/NPCMapIcon7,
	"kitchen-witch" : $NPCMarkers/NPCMapIcon2,
	"housekeeper" : $NPCMarkers/NPCMapIcon5,
	"wolf-witch" : $NPCMarkers/NPCMapIcon8,
	#"dead-witch" : ""
}

func _ready():
	MapManager.map = self
	TimeManager.time_change.connect(change_layout)
	GameManager.map = self
	#generate(to_local(), to_local())
	#$DottedLine.setup($Rooms/HallwayMinimapRoom.position, $Rooms/EmoMinimapRoom.global_position)
	#$DottedLine2.setup($Rooms/HallwayMinimapRoom.position, $Rooms/ClockMinimapRoom.global_position)

#func _process(delta):
	#if Input.is_action_just_pressed("ui_down"):
		#change_layout(1)
	#if Input.is_action_just_pressed("ui_up"):
		#change_layout(2)
		#
	#if Input.is_action_just_pressed("ui_right"):
		#change_layout(3)

func change_layout(time : int):
	MapManager.map_focusable = false
	#current_layout += 1
	#if current_layout >= 3:
		#current_layout = 0
	#map_moving_animator.play("Layout1")
	map_moving_animator.play("LayoutChange" + str(time+1))
	await map_moving_animator.animation_finished
	if !GameManager.intro_scene:
		MapManager.character_set_up()
		await get_tree().create_timer(0.45).timeout
	MapManager.map_focusable = true


#func movement(room1, room2):
	#player_animation_player.play("start_move")
	#await player_animation_player.animation_finished
	#player_animation_player.play(map_moving_animator)
	
	
