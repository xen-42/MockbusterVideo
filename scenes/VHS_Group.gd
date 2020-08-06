extends Node2D

const global = preload("res://scripts/Global.gd")

# Used for randomly making orders
var rng = RandomNumberGenerator.new()

var min_x = 300
var max_x = 720
var row_size = 5
var spacing = (max_x - min_x) / row_size

var start_y = 90
var end_y = 250
var row_spacing = 130

var start_position = Vector2(500, 132)

# Need the VHS_pair type for creating VHS
const VHS_Pair = preload("res://scenes/VHS_Pair.tscn")

var child_items = []

onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

func create_order(current_month, current_day, number):
	var expected_cost = 0
	
	var number_of_VHS = rng.randi_range(1, number)
	
	var start_x = 0.5 * (min_x + max_x - spacing * number_of_VHS)
	for i in range(0, number_of_VHS):
		#var start_position = Vector2(start_x + spacing * i, start_y)
		var end_position = Vector2(start_x + spacing * i, end_y + rng.randi_range(0, 12))
		if i > row_size:
			end_position.y += row_spacing
		
		var vhs = VHS_Pair.instance()
		vhs.set_position(start_position)
		
		# Give VHS random settings
		vhs.VHS_type = global.BinTypeEnum.values()[rng.randi()%global.BinTypeEnum.size()]
		
		var flag_late = false
		if vhs.VHS_type != global.BinTypeEnum.PURCHASE and vhs.VHS_type != global.BinTypeEnum.RENTAL:
			if rng.randi()%2:
				vhs.is_rewound = false
			else:
				vhs.is_rewound = true
			
			# Random due date
			var month = current_month
			var day = rng.randi_range(current_day - 7, current_day + 7)

			if day < current_day:
				flag_late = true
			
			if day < 0:
				month -= 1
				if month <= 0:
					month += 12
				day += Global.month_length[month - 1]
			elif day > Global.month_length[month - 1]:
				month += 1
				if month > 12:
					month -= 12
				day -= Global.month_length[month - 1]
			vhs.due_month = month
			vhs.due_date = day
		
		# Have the VHS come in from where the character will be standing
		tween.interpolate_property(vhs, "position",
			start_position, end_position, 1,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.interpolate_property(vhs, "modulate",
			Color(1,1,1,0), Color(1,1,1,1), 1,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		
		#if not vhs.is_rewound:
			#expected_cost += Global.prices[Global.FEE_TYPE_ENUM.Rewind]
		match vhs.VHS_type:
			Global.BinTypeEnum.RENTAL:
				expected_cost += Global.prices[Global.FEE_TYPE_ENUM.Rental]
			Global.BinTypeEnum.PURCHASE:
				expected_cost += Global.prices[Global.FEE_TYPE_ENUM.Purchase]
			Global.BinTypeEnum.TRASH:
				expected_cost += Global.prices[Global.FEE_TYPE_ENUM.Purchase]
			Global.BinTypeEnum.REPAIR:
				expected_cost += Global.prices[Global.FEE_TYPE_ENUM.Repair]
		if flag_late:
			expected_cost += Global.prices[Global.FEE_TYPE_ENUM.Late]
		
		self.add_child(vhs)
		child_items = child_items + [vhs]
	return expected_cost
	
