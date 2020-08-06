extends Node2D

export var day_length = 60

var time = 0

var freeze_time = false

var large_hand_rotations = day_length / 2.0 #twice per day
var small_hand_rotations = day_length / 24.0 

var large_hand_omega = deg2rad(360 / large_hand_rotations)
var small_hand_omega = deg2rad(360 / small_hand_rotations)

onready var large_hand = $ClockPosition/LargeHand
onready var small_hand = $ClockPosition/SmallHand
onready var clock_pos = $ClockPosition

signal end_day

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("end_day", get_node("/root/Level"), "_on_Level_end_day")
	get_node("/root/Level").connect("start_day", self, "_on_Clock_start_day")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
		
	if freeze_time == false:
		if time > day_length:
			emit_signal("end_day")
			freeze_time = true
			time = 0
			large_hand.rotation = 0
			small_hand.rotation = 0
		else:
			large_hand.rotation += large_hand_omega * delta
			if large_hand.rotation > 2 * PI:
				large_hand.rotation -= 2 * PI
			
			small_hand.rotation += small_hand_omega * delta
			if small_hand.rotation > 2 * PI:
				small_hand.rotation -= 2 * PI
	else:
		clock_pos.position.x = (0.5 * sin(6 * PI * time))

func _on_Clock_start_day():
	time = 0
	large_hand.rotation = 0
	small_hand.rotation = 0
	freeze_time = false
