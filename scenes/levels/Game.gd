extends Node2D

const demo_week_type = preload("res://scenes/levels/demo/DemoWeek.tscn")
const demo_endless_week_type = preload("res://scenes/levels/demo/EndlessWeek.tscn")
var week = null

func _ready():
	start_week(Global.endless_mode)

func start_week(endless_mode):
	if not endless_mode:
		week = demo_week_type.instance()
	else:
		week = demo_endless_week_type.instance()
	week.connect("tree_exiting", self, "_on_Week_tree_exiting")
	add_child(week)

func _on_Week_tree_exiting():
	var date = week.date
	var new_date = Global.day_calculator(date[0], date[1], date[2], 2)
	start_week(false)
	week.date = new_date
