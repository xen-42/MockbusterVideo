extends Node2D

enum STOCK_TYPE {loyalty, cash}
export(STOCK_TYPE) var stock_type = STOCK_TYPE.cash
var last_seven_days = []

var width = 0
var height = 0
var x = []

onready var colour_rect = $ColorRect
onready var label = $Node2D/Label

# Variables for showing changes in the value
onready var counter_label = $CounterNode/CounterLabel
onready var delta_counter_node = $CounterNode/DeltaCounterNode
onready var delta_counter_label = $CounterNode/DeltaCounterNode/DeltaCounterLabel
var delta_counter_node_position = Vector2(0,0)
var old_counter = 0
var delta_fade_time = 1.5

onready var tween = $Tween

export var counter_warning_threshold = 20
export var counter_danger_threshold = 0

var good_colour = Color(0, 0.9, 0, 1)
var warning_colour = Color(1, 0.5, 0, 1)
var danger_colour = Color(1, 0, 0, 1)

var gradient = Gradient.new()

var lines = []

var counted_transactions = 20
var line_x_spacing = 1

var update_queue = []
var is_updating = false
signal update_value_done

# Called when the node enters the scene tree for the first time.
func _ready():
	var starting_value = 0
	if stock_type == STOCK_TYPE.cash:
		starting_value = Global.cash
		last_seven_days = Global.cash_record
		label.text = "Cash"
	elif stock_type == STOCK_TYPE.loyalty:
		starting_value = Global.loyalty
		last_seven_days = Global.loyalty_record
		label.text = "Loyalty"
	
	# For counter, delta counter
	old_counter = starting_value
	delta_counter_node.modulate = Color(1,1,1,0)
	delta_counter_node_position = delta_counter_node.position
	
	width = colour_rect.rect_size.x 
	height = colour_rect.rect_size.y / 2
	line_x_spacing = width / (counted_transactions - 1)
	
	x = []
	for i in range(0, counted_transactions):
		x.append(i * line_x_spacing)
		last_seven_days.append(starting_value)
	
	for i in range(0, counted_transactions-1):
		var new_line = Line2D.new()
		new_line.width = 1
		new_line.z_index = 1
		new_line.position = Vector2(-32 + i * line_x_spacing, 0)
		new_line.points = [Vector2(0,0), Vector2(line_x_spacing, 0)]
		new_line.gradient = Gradient.new()
		self.add_child(new_line)
		lines.append(new_line)
	
	_add_daily_cash(starting_value)
	setup_lines()
	
	connect("tree_exiting", self, "_on_Stocks_tree_exiting")

func set_gradient(array):
	pass

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

func setup_lines():
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
	
	for i in range(0, last_seven_days.size()):
		y[i] *= -height/2.0
		
	for i in range(0, counted_transactions-1):
		var p1 = Vector2(0, y[i])
		var p2 = Vector2(line_x_spacing, y[i+1])
		lines[i].points = [p1, p2]
		lines[i].gradient.colors = [get_colour(last_seven_days[i]), get_colour(last_seven_days[i+1])]

func _add_daily_cash(money):
	# Change array of daily cash
	for i in range(0, counted_transactions-1):
		last_seven_days[i] = last_seven_days[i + 1]
	last_seven_days[counted_transactions-1] = money
	
	setup_lines()

func get_colour(val):
	if val < counter_danger_threshold:
		return danger_colour
	elif val < counter_warning_threshold:
		return warning_colour
	else:
		return good_colour

func update_value(counter, message):
	update_queue.append([counter, message])
	if not is_updating:
		_update_counter_label()

func _update_counter_label():
	var counter = update_queue[0][0]
	var message = update_queue[0][1]
	update_queue.remove(0)
	
	_add_daily_cash(counter)
	
	var delta_counter = counter - old_counter
	if delta_counter != 0:
		is_updating = true
		
		var start_colour = Color(1,1,1,1)
		var end_colour = Color(1,1,1,1)
		
		if delta_counter > 0:
			start_colour = Color(0,1,0,1)
			end_colour = Color(0,1,0,0)
			if stock_type == STOCK_TYPE.cash:
				delta_counter_label.text = "+$%.2f\n%s" % [delta_counter, message]
			else:
				delta_counter_label.text = "+%d\n%s" % [delta_counter, message]
		else:
			start_colour = Color(1,0,0,1)
			end_colour = Color(1,0,0,0)
			if stock_type == STOCK_TYPE.cash:
				delta_counter_label.text = "$%.2f\n%s" % [delta_counter, message]
			else:
				delta_counter_label.text = "%d\n%s" % [delta_counter, message]
		
		tween.interpolate_property(delta_counter_node, "position",
			delta_counter_node_position, delta_counter_node_position + Vector2(-15, 15), delta_fade_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(delta_counter_node, "modulate",
			start_colour, end_colour, delta_fade_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		# Once the text has faded out, updating will be done
		tween.interpolate_callback(self, delta_fade_time, "_update_value_done")
		tween.start()
	
	old_counter = counter
	
	if counter < 0:
		if stock_type == STOCK_TYPE.cash:
			counter_label.text = "-$%.2f" % -counter
		else:
			counter_label.text = "-%d" % -counter
	else:
		if stock_type == STOCK_TYPE.cash:
			counter_label.text = "$%.2f" % counter
		else:
			counter_label.text = "%d" % counter
	
	if counter < counter_danger_threshold:
		counter_label.add_color_override("font_color", danger_colour)
	elif counter < counter_warning_threshold:
		counter_label.add_color_override("font_color", warning_colour)
	else:
		counter_label.add_color_override("font_color", good_colour)

func _update_value_done():
	if update_queue.size() == 0:
		is_updating = false
		emit_signal("update_value_done")
	else:
		_update_counter_label()

func _on_Stocks_tree_exiting():
	if stock_type == STOCK_TYPE.cash:
		Global.cash_record = last_seven_days
	elif stock_type == STOCK_TYPE.loyalty:
		Global.loyalty_record = last_seven_days
