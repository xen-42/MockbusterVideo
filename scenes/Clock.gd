extends Node2D

export var seconds_per_hour = 6.0
export var opening_time = 9.0
export var closing_time = 17.0

var sunrise = 9.0
var sunset = 17.0

var time = 0
var frozen_time = 0
var freeze_time = false

var day_length = seconds_per_hour * 24
var large_hand_rotations = day_length / 24.0 
var small_hand_rotations = day_length / 2.0 

var large_hand_omega = deg2rad(360 / large_hand_rotations)
var small_hand_omega = deg2rad(360 / small_hand_rotations)

onready var large_hand = $ClockPosition/LargeHand
onready var small_hand = $ClockPosition/SmallHand
onready var clock_pos = $ClockPosition

signal end_day

# Called when the node enters the scene tree for the first time.
func _ready():
	set_time(opening_time * seconds_per_hour)

func set_time(new_time):
	time = new_time
	large_hand.rotation = fmod(large_hand_omega * new_time, 2 * PI)
	small_hand.rotation = fmod(small_hand_omega * new_time, 2 * PI)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var _frozen_time = 0
func _process(delta):
	if freeze_time == false:
		time += delta
		if time > closing_time * seconds_per_hour:
			emit_signal("end_day")
			stop_clock()
			set_time(closing_time * seconds_per_hour)
			SoundEffects.play("ticking.wav")
		else:
			large_hand.rotation += large_hand_omega * delta
			if large_hand.rotation > 2 * PI:
				large_hand.rotation -= 2 * PI
			
			small_hand.rotation += small_hand_omega * delta
			if small_hand.rotation > 2 * PI:
				small_hand.rotation -= 2 * PI
			SoundEffects.stop("ticking.wav")
	else:
		frozen_time += delta
		large_hand.rotation = large_hand_omega * (time + 0.05 * cos(10 * frozen_time))

func _on_Clock_start_day():
	start_clock()

func get_time():
	return time * seconds_per_hour

func get_daylight():
	return ((time / seconds_per_hour) - sunrise) / (sunset - sunrise)

func start_clock():
	freeze_time = false

func stop_clock():
	freeze_time = true
