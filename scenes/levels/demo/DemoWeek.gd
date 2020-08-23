extends Node2D

const day1 = preload("res://scenes/levels/demo/Day1.tscn")
const day2 = preload("res://scenes/levels/demo/Day2.tscn")
const day3 = preload("res://scenes/levels/demo/Day3.tscn")
const day4 = preload("res://scenes/levels/demo/Day4.tscn")
const day5 = preload("res://scenes/levels/demo/Day5.tscn")

var days = [day1, day2, day3, day4, day5]
var level = null

var day_counter = 0
var week_length = 5

var date = [6, 10, 1996]

# Called when the node enters the scene tree for the first time.
func _ready():
	new_day(day1)

func new_day(type):
	level = type.instance()
	
	level.current_day = date[0]
	level.current_month = date[1]
	level.current_year = date[2]
	level.day_string = Global.day_string[day_counter]
	
	level.connect("tree_exiting", self, "_on_Level_tree_exiting")
	self.add_child(level)

# When a day gets deleted
func _on_Level_tree_exiting():
	# We change the day
	date = Global.day_calculator(date[0], date[1], date[2], 1)
	day_counter += 1
	if day_counter < week_length:
		new_day(days[day_counter])
	else:
		queue_free()
