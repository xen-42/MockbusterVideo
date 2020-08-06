extends Node2D

enum STOCK_TYPE {loyalty, cash}
export(STOCK_TYPE) var stock_type = STOCK_TYPE.cash
var last_seven_days = []

var width = 0
var height = 0
var x = []

onready var colour_rect = $ColorRect
onready var line = $StockLine
onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	var starting_value = 0
	if stock_type == STOCK_TYPE.cash:
		starting_value = Global.STARTING_CASH
		label.text = "Cash"
	elif stock_type == STOCK_TYPE.loyalty:
		starting_value = Global.STARTING_LOYALTY
		label.text = "Loyalty"
	
	width = colour_rect.rect_size.x / 2
	height = colour_rect.rect_size.y / 2
	var line_x_spacing = width / 5.0
	x = [0, 1, 2, 3, 4, 5, 6]
	for i in range(0, 7):
		x[i] *= line_x_spacing
	
	last_seven_days = [
		starting_value,
		starting_value,
		starting_value,
		starting_value,
		starting_value,
		starting_value,
		starting_value
	]
	add_daily_cash(starting_value)

func get_min_max(arr):
	var arr2 = arr.duplicate()
	arr2.sort()
	return Vector2(arr2[0], arr2[arr2.size() - 1])

func average(arr):
	var avg = 0
	for a in arr.duplicate():
		avg += a
	avg /= arr.size()
	return avg

func add_daily_cash(money):
	# Change array of daily cash
	for i in range(0, 6):
		last_seven_days[i] = last_seven_days[i + 1]
	last_seven_days[6] = money
	
	# Center and normalize cash then fit to color rect
	var avg = average(last_seven_days)
	var y = last_seven_days.duplicate()
	for i in range(0, last_seven_days.size()):
		y[i] -= avg
	
	var min_max = get_min_max(y)
	var magnitude = max(abs(min_max.x), abs(min_max.y))
	
	if magnitude != 0:
		for i in range(0, y.size()):
			y[i] /= magnitude
	
	#Values are upsidedown idk why nor do i care
	for i in range(0, last_seven_days.size()):
		y[i] *= -height
	
	line.set_points([
		Vector2(x[0], y[0]),
		Vector2(x[1], y[1]),
		Vector2(x[2], y[2]),
		Vector2(x[3], y[3]),
		Vector2(x[4], y[4]),
		Vector2(x[5], y[5]),
		Vector2(x[6], y[6]),
		])
	

