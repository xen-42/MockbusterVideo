extends Node2D
class_name Week

var level = null

var day_counter = 0
var week_counter = 0
var week_length = 5

var previous_date = null

signal create_day(day)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# When a day gets deleted
func _on_Level_tree_exiting():
	# We change the day
	var date = Global.day_calculator(previous_date[0], previous_date[1], previous_date[2], 1)
	previous_date = date
	day_counter += 1
	if day_counter < week_length:
		new_day(date)
	else:
		queue_free()

# Function to be overloaded
func _get_day():
	pass

func new_day(date):
	if previous_date == null:
		previous_date = date
	
	level = _get_day().instance()
	
	level.current_day = date[0]
	level.current_month = date[1]
	level.current_year = date[2]
	level.day_string = Global.day_string[day_counter]
	level.day_number = day_counter
	
	level.connect("tree_exiting", self, "_on_Level_tree_exiting")
	self.add_child(level)
	
	emit_signal("create_day", level)
