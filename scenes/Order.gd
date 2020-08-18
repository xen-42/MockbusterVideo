extends Node2D

onready var VHS_scene = preload("res://scenes/items/VHS.tscn")

# Likelihood of each buyable item
export(int, 100) var VHS_likelihood = 50
export(int, 100) var DVD_likelihood = 0
export(int, 100) var popcorn_likelihood = 0

# Likelihood of VHS/DVD subtypes
export(int, 100) var return_likelihood = 50
export(int, 100) var rental_likelihood = 50
export(int, 100) var purchase_likelihood = 50

# Likelihood of return subtypes
export(int, 100) var normal_likelihood = 50
export(int, 100) var repair_likelihood = 50
export(int, 100) var trash_likelihood = 50

export(int, 100) var rewind_likelihood = 0
export(int, 100) var late_likelihood = 50

# Used for randomly making orders
var rng = RandomNumberGenerator.new()

# Used for placing items
var min_x = 300
var max_x = 720
var row_size = 5
var spacing = (max_x - min_x) / row_size

var start_y = 90
var end_y = 250
var row_spacing = 130

var start_position = Vector2(500, 132)

var child_items = []

onready var tween = $Tween

var day = 0
var month = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

func get_option_from_probability(options, probabilities):
	if options.size() != probabilities.size():
		push_error("Options and probabilities must have matching sizes!")
	
	# Going to sum the total of the probabilities since it might not be 100
	var total = Global.sum(probabilities)
	var random_int = rng.randi_range(0, total)
	var length = options.size()
	
	for i in range(0, length):
		if random_int > probabilities[0]:
			random_int -= probabilities[0]
			options.erase(options[0])
			probabilities.erase(options[0])
		else:
			return options[0]
	push_error("This should have returned already")

func create_item(item_types):
	# Create VHS tapes
	if item_types.has(Global.ItemTypeEnum.VHS):
		var vhs = VHS_scene.instance()
		vhs.types = item_types
		
		var due_date = pick_due_date(item_types.has(Global.ItemTypeEnum.LATE))
		vhs.due_day = due_date[0]
		vhs.due_month = due_date[1]
		
		return vhs
	
	return null

func pick_due_date(is_late):
	var due_date = day
	var due_month = month
	
	if is_late:
		due_date -= rng.randi_range(1, 7)
		
		#Check if due_date is less than 1 and move back month
		if due_date <= 0:
			due_month -= 1
			
			# If month is less than 1 move back a year
			if due_month < 0:
				due_month += 12
			
			due_date += Global.month_length[due_month - 1]
	else:
		due_date += rng.randi_range(0, 3)
		
		#Check if due_date is greater than month length and move forward a month
		if due_date > Global.month_length[due_month - 1]:
			due_date -= Global.month_length[due_month - 1]
			
			due_month += 1
			# If month is over 12 move forward a year
			if due_month > 12:
				due_month -= 12
	
	return [due_date, due_month]

func create_order(current_month, current_day, number):
	day = current_day
	month = current_month
	
	# Create a dictionary of every possible item type
	var order = {}
	for item_type in Global.ItemTypeEnum.values():
		order[item_type] = 0
	
	var number_of_items = rng.randi_range(1, number)
	
	# Used for item placement
	var start_x = 0.5 * (min_x + max_x - spacing * number_of_items)
	
	for i in range(0, number_of_items):
		var item_types = []
		
		# First we pick if its a VHS, DVD, or popcorn
		var item_type = get_option_from_probability(
			[Global.ItemTypeEnum.VHS, Global.ItemTypeEnum.DVD, Global.ItemTypeEnum.POPCORN],
			[VHS_likelihood, DVD_likelihood, popcorn_likelihood]
		)
		item_types.append(item_type)
		
		# Then we pick if its a return, a rental, or a purchase
		if item_type == Global.ItemTypeEnum.VHS or item_type == Global.ItemTypeEnum.DVD:
			var movie_type = get_option_from_probability(
				[Global.ItemTypeEnum.RETURN, Global.ItemTypeEnum.RENTAL, Global.ItemTypeEnum.PURCHASE],
				[return_likelihood, rental_likelihood, purchase_likelihood]
			)
			item_types.append(movie_type)
			
			# Then if its a return, we pick if its normal, a repair, or broken
			if movie_type == Global.ItemTypeEnum.RETURN:
				var return_type = get_option_from_probability(
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
		var new_item = create_item(item_types)
		
		if new_item != null:
			# Have the item come in from where the character will be standing
			var end_position = Vector2(start_x + spacing * i, end_y + rng.randi_range(0, 12))
			if i > row_size:
				end_position.y += row_spacing
	
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
			
			self.add_child(new_item)
			child_items.append(new_item)
		
	return order
