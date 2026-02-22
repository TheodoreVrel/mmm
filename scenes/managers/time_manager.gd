extends Node2D

const TIME : Array = ["morning", "day","night"]

var current_time : String = TIME[1]

signal time_change

func set_time(time: String):
	current_time = time
	print("ddddddddddddddddddddddddddddddddddddddddddddddddd",TIME.find(time))
	time_change.emit(TIME.find(time))

func time_pass():
	var time_idx : int = TIME.find(current_time)
	if time_idx == 2:
		set_time(TIME[0])
	else : set_time(TIME[time_idx + 1])
