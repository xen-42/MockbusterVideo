extends Week

const day1 = preload("res://scenes/levels/demo/Day1.tscn")
const day2 = preload("res://scenes/levels/demo/Day2.tscn")
const day3 = preload("res://scenes/levels/demo/Day3.tscn")
const day4 = preload("res://scenes/levels/demo/Day4.tscn")
const day5 = preload("res://scenes/levels/demo/Day5.tscn")

var days = [day1, day2, day3, day4, day5]

func ready():
	#date = [6, 10, 1996]
	.ready()

func _get_day():
	return days[day_counter]
