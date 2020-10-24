extends Node2D

onready var VHS_scene = preload("res://scenes/items/VHS.tscn")
onready var popcorn_scene = preload("res://scenes/items/Popcorn.tscn")

# Likelihood of each buyable item
var VHS_likelihood = 50
var DVD_likelihood = 0
var popcorn_likelihood = 50

# Likelihood of VHS/DVD subtypes
var return_likelihood = 50
var rental_likelihood = 50
var purchase_likelihood = 50

# Likelihood of return subtypes
var normal_likelihood = 50
var repair_likelihood = 50
var trash_likelihood = 50

var rewind_likelihood = 0
var late_likelihood = 50

# Used for randomly making orders
var rng = RandomNumberGenerator.new()

# Used for placing items
var min_x = 126
var max_x = 226
var row_size = 4
var spacing = (max_x - min_x) / row_size

var start_y = 30
var end_y = 94
var row_spacing = 36

var start_position = Vector2(167, 44)

var child_items = []

onready var tween = $Tween

var day = 0
var month = 0

signal new_item(item)
signal order_complete()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

func _get_option_from_probability(options, probabilities):
	if options.size() != probabilities.size():
		push_error("Options and probabilities must have matching sizes!")
	
	# Going to sum the total of the probabilities since it might not be 100
	var total_weights = Global.sum(probabilities)
	var random_int = rng.randi_range(0, total_weights)
	
	for i in range(0, options.size()):
		if random_int <= probabilities[i] and probabilities[i] != 0:
			return options[i]
		random_int -= probabilities[i]
	push_error("This should have returned already")

func _create_item(item_types):
	# Create VHS tapes
	var item = null
	
	if item_types.has(Global.ItemTypeEnum.VHS):
		var vhs = VHS_scene.instance()
		vhs.types = item_types
		
		var due_date = _pick_due_date(item_types.has(Global.ItemTypeEnum.LATE))
		vhs.due_day = due_date[0]
		vhs.due_month = due_date[1]
		
		item = vhs
	elif item_types.has(Global.ItemTypeEnum.POPCORN):
		var popcorn = popcorn_scene.instance()
		popcorn.types = item_types
		
		item = popcorn
	else:
		push_error("Item is null")
	
	emit_signal("new_item", item)
	return item

func _pick_due_date(is_late):
	var due_date = day
	var due_month = month
	var change = 0
	
	if is_late:
		change = -rng.randi_range(1, 7)
	else:
		change = rng.randi_range(0, 3)
	var new_date = Global.day_calculator(due_date, due_month, 0, change)
	
	return [new_date[0], new_date[1]]

func create_order(current_month, current_day, number):
	day = current_day
	month = current_month
	
	# Create a dictionary of every possible item type
	var order = {}
	for item_type in Global.ItemTypeEnum.values():
		order[item_type] = 0
	
	var number_of_items = clamp(number + rng.randi_range(-1, 0), 1, 6)
	
	for i in range(0, number_of_items):
		var item_types = []
		
		# First we pick if its a VHS, DVD, or popcorn
		var item_type = _get_option_from_probability(
			[Global.ItemTypeEnum.VHS, Global.ItemTypeEnum.DVD, Global.ItemTypeEnum.POPCORN],
			[VHS_likelihood, DVD_likelihood, popcorn_likelihood]
		)
		item_types.append(item_type)
		
		# Then we pick if its a return, a rental, or a purchase
		if item_type == Global.ItemTypeEnum.VHS or item_type == Global.ItemTypeEnum.DVD:
			var movie_type = _get_option_from_probability(
				[Global.ItemTypeEnum.RETURN, Global.ItemTypeEnum.RENTAL, Global.ItemTypeEnum.SALE],
				[return_likelihood, rental_likelihood, purchase_likelihood]
			)
			item_types.append(movie_type)
			
			# Then if its a return, we pick if its normal, a repair, or broken
			if movie_type == Global.ItemTypeEnum.RETURN:
				var return_type = _get_option_from_probability(
					[Global.ItemTypeEnum.NORMAL, Global.ItemTypeEnum.REPAIR, Global.ItemTypeEnum.TRASH],
					[normal_likelihood, repair_likelihood, trash_likelihood]
				)
				item_types.append(return_type)
				
				# We also pick if its late
				if rng.randi_range(0, 100) < late_likelihood:
					item_types.append(Global.ItemTypeEnum.LATE)
				
				# If its a normal VHS return, we pick if its rewound
				if item_type == Global.ItemTypeEnum.VHS and return_type == Global.ItemTypeEnum.NORMAL:
					if rng.randi_range(0, 100) < rewind_likelihood:
						item_types.append(Global.ItemTypeEnum.REWIND)
		
		# Create an object from these types
		var new_item = _create_item(item_types)
		
		if new_item != null:
			# Have the item come in from where the character will be standing
			
			#var number_in_row = number_of_items if number_of_items <= row_size else row_size
			# If theres only one row
			var number_in_row = number_of_items
			# If theres two rows
			if number_of_items > row_size:
				#First row
				if i < row_size:
					number_in_row = row_size
				#Second row
				else:
					number_in_row = number_of_items - row_size
			
			var start_x = 0.5 * (min_x + max_x - spacing * number_in_row)
			var end_position = Vector2(
				start_x + spacing * (i % row_size),
				end_y + row_spacing * (0 if i < row_size else 1)
			)
	
			new_item.set_position(start_position)
			
			tween.interpolate_property(new_item, "position",
				start_position, end_position, 1,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.interpolate_property(new_item, "modulate",
				Color(1,1,1,0), Color(1,1,1,1), 1,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.start()
			
			# Add the item to the order list
			for item in item_types:
				order[item] += 1
			
			self.get_parent().get_parent().add_child(new_item)
			new_item.connect("item_removed", self, "_on_Order_item_removed")
			child_items.append(new_item)
		
	return order

func _on_Order_item_removed(item):
	if child_items.has(item):
		child_items.erase(item)
		if child_items.size() == 0:
			emit_signal("order_complete")
