extends Node2D

var cash = Global.STARTING_CASH
var loyalty = 50.0

var current_month = 8
var current_day = 22
var day_counter = 1

var flag_end_day = false

onready var ui = $UI
onready var cash_label = $UI/ColorRect/CashLabel
onready var loyalty_label = $UI/ColorRect/LoyaltyLabel
onready var transaction_button = $UI/ColorRect/FeeContainer/EnterButton
onready var money = $Money
onready var VHS = $VHS_Group
onready var calendar = $Calendar

onready var customer = $Customer

var treating_customer = false
var expected_cost = 0

var daily_fee = 50

signal start_day

# Called when the node enters the scene tree for the first time.
func _ready():
	ui.update_cash_label(cash)
	ui.update_loyalty_label(loyalty)
	calendar.set_date(current_month, current_day)
	
	money.connect("cash_signal", self, "_on_Level_cash_signal")
	
	customer.enter()

func _process(delta):
	if treating_customer and VHS.child_items.size() == 0:
		print("All VHS are dealt with")
		transaction_button.disabled = false
		treating_customer = false

func next_customer():
	expected_cost = VHS.create_order(current_month, current_day, clamp(day_counter/2, 1, 5))
	print("Expected cost: ", expected_cost)
	treating_customer = true
	transaction_button.disabled = true
	
	# Only want to increment the date when we're done with a customer
	if flag_end_day:
		increment_date()
		emit_signal("start_day")
		flag_end_day = false

func _on_Level_customer_ready():
	print("New customer is ready")
	next_customer()

func _on_Level_customer_cleared():
	customer.enter()

func _on_Level_cash_signal(ammount):
	print("recieved ", ammount)
	change_cash(ammount, "Transaction")
	ui.set_total(0)
	customer.exit()

func _on_Level_VHS_signal(bin_type, VHS_type, rewound):
	print("Recieved VHS type %s in bin type %s, rewound = %s" % [VHS_type, bin_type, rewound])
	# Put logic for VHS stuff

func _on_Level_complete_purchase(purchase_total):
	#Compare how much is being charged versus what is owed
	var flag_customer_refusal = false
	if purchase_total != 0 or expected_cost != 0:
		var percentage_difference = (purchase_total - expected_cost) / ((expected_cost + purchase_total) / 2) * 100
		var absolute_difference = purchase_total - expected_cost
		print("% diff: ", percentage_difference)
		
		#Update loyalty based on difference between ammount demanded and ammount owed
		var delta_loyalty = -clamp(absolute_difference, -10, 10)
		if delta_loyalty >= 0:
			delta_loyalty += 0
		var message = "Fair transaction"
		if delta_loyalty > 5:
			message = "Nice discount!"
		elif delta_loyalty < 0:
			message = "Steep prices"
		elif delta_loyalty < -5:
			message = "What a rip-off"
		elif delta_loyalty == -10:
			message = "No way!"
			flag_customer_refusal = true
		change_loyalty(delta_loyalty, message)
	
	if purchase_total != 0 and not flag_customer_refusal:
		money.create_bills(purchase_total)
	else:
		ui.set_total(0)
		customer.exit()

func _on_Level_end_day():
	flag_end_day = true
	
func change_loyalty(change, message):
	print(message)
	loyalty += change
	ui.update_loyalty_label(loyalty)

func change_cash(change, message):
	print(message)
	cash += change
	ui.update_cash_label(cash)

func increment_date():
	current_day += 1
	if current_day > Global.month_length[current_month - 1]:
		current_day = 1
		current_month += 1
		if current_month > 12:
			current_month -= 12
	calendar.change_date(current_month, current_day)
	change_cash(-daily_fee, "Daily expenses")
	ui.update_day_end(cash, loyalty)
	day_counter += 1
	
	
