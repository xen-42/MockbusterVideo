extends Node2D

const level_type = preload("res://scenes/levels/demo/EndlessLevel.tscn")
var level = null

var day_counter = 0
var week_length = 5

var date = [13, 10, 1996]

# Called when the node enters the scene tree for the first time.
func _ready():
	new_day(level_type)

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
		new_day(level_type)
	else:
		queue_free()
