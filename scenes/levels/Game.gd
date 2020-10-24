extends Node2D

onready var pause = $Pause/CanvasLayer/PausePopup

const demo_week_type = preload("res://scenes/levels/demo/DemoWeek.tscn")
const demo_endless_week_type = preload("res://scenes/levels/demo/EndlessWeek.tscn")
var week = null
var week_counter = 0
var new_date = [6, 10, 1996]

func _ready():
	Global.reset()
	start_week(Global.endless_mode)

func start_week(endless_mode):
	print("new week")
	if not endless_mode:
		week = demo_week_type.instance()
	else:
		week = demo_endless_week_type.instance()
		week.week_counter = week_counter
	week.connect("tree_exiting", self, "_on_Week_tree_exiting")
	week.connect("create_day", self, "_on_Week_create_day")
	add_child(week)
	week.new_day(new_date)

func _on_Week_tree_exiting():
	week_counter += 1
	var date = new_date
	new_date = Global.day_calculator(date[0], date[1], date[2], 7)
	start_week(true)

func _on_Week_create_day(day):
	print("New day")
	day.connect("lose", self, "_on_Day_lose")
	day.connect("win", self, "_on_Day_win")

func _on_Day_win():
	pause.end_game(true)

func _on_Day_lose():
	pause.end_game(false)

func _exit_tree():
	SoundEffects.stop(Global.night_song)
