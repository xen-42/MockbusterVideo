extends Node2D

var cash = Global.STARTING_CASH
var loyalty = 50.0

var bankrupt_cash = -50
var win_cash = 200

var current_month = 8
var current_day = 22
var day_counter = 1

var flag_end_day = false

var paused = false

onready var ui = $GameScene/UI
onready var cash_label = $GameScene/UI/ColorRect/CashLabel
onready var loyalty_label = $GameScene/UI/ColorRect/LoyaltyLabel
onready var transaction_button = $GameScene/UI/ColorRect/FeeContainer/EnterButton
onready var money = $GameScene/Money
onready var VHS = $GameScene/VHS_Group
onready var calendar = $GameScene/Calendar
onready var register = $GameScene/Register

onready var customer = $GameScene/Customer

onready var tween = $GameScene/BonusTween

onready var game_scene = $GameScene
onready var pause_menu = $Pause/CanvasLayer/PausePopup

var treating_customer = false
var flag_customer_refusal = false
var flag_bad_transaction = false
var expected_cost = 0

var flag_bonus = true

var daily_fee = 30

var rng = RandomNumberGenerator.new()

signal start_day

var give_away_vhs_text = [
	"Um... I didn't ask for this.",
	"Why did you give me this?",
	"I guess I'll take this"
]
var took_away_vhs_text = [
	"Hey I wanted that!",
	"Huh?",
	"I think I'll switch to Webflix..."
]
var lost_purchase_text = [
	"I'm taking my business elsewhere...",
	"I'm not shopping here anymore..."
]
var ambivalent_purchase_text = [
	"Have a good day.",
	"Understandable. Have a nice day."
]
var return_text = [
	"Thanks.",
	"See you later."
]
var good_purchase_text = [
	"Thanks!",
	"Thanks for the discount!",
	"Thank you very cool."
]
var bad_purchase_text = [
	"That seems expensive...",
	"Are you sure that's the price?",
	"If you say so..."
]
var ripoff_purchase_text = [
	"What a rip-off!",
	"I'm not shopping here again...",
]
var refusal_purchase_text = [
	"I'm not paying that!",
	"No way!"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	ui.update_cash_label(cash, "")
	ui.update_loyalty_label(loyalty, "")
	calendar.set_date(current_month, current_day)
	
	money.connect("cash_signal", self, "_on_Level_cash_signal")
	
	customer.enter()

func _process(delta):
	if treating_customer and VHS.child_items.size() == 0:
		transaction_button.disabled = false
		treating_customer = false

func next_customer():
	expected_cost = VHS.create_order(current_month, current_day, clamp(day_counter, 1, 5))
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
	change_cash(ammount, "")
	ui.set_total(0)
	register.on_finish_transaction()
		# Want to give time for the speech bubble to show
	tween.interpolate_callback(self, 0.4, "customer_leave")
	tween.start()

func _on_Level_VHS_signal(bin_type, VHS_type, rewound):
	print("Recieved VHS type %s in bin type %s, rewound = %s" % [VHS_type, bin_type, rewound])
	# Put logic for VHS stuff
	
	# Special logic for giving the wrong thing to the customer
	if bin_type == Global.BinTypeEnum.PURCHASE:
		if VHS_type != Global.BinTypeEnum.PURCHASE and VHS_type != Global.BinTypeEnum.RENTAL:
			customer.speech(give_away_vhs_text[rng.randi() % give_away_vhs_text.size()])
			change_cash(-8.95, "Gave away VHS")
	else:
		if bin_type != VHS_type:
			change_cash(-5, "Wrong bin")
		# Not giving VHS to customer
		if VHS_type == Global.BinTypeEnum.PURCHASE or VHS_type == Global.BinTypeEnum.RENTAL:
			customer.speech(took_away_vhs_text[rng.randi() % took_away_vhs_text.size()])
			flag_bad_transaction = true


func _on_Level_complete_purchase(purchase_total):
	flag_customer_refusal = false
	
	#Compare how much is being charged versus what is owed
	var message = ambivalent_purchase_text[rng.randi() % ambivalent_purchase_text.size()]
	if purchase_total != 0 or expected_cost != 0:
		var percentage_difference = (purchase_total - expected_cost) / ((expected_cost + purchase_total) / 2) * 100
		var absolute_difference = purchase_total - expected_cost
		print("% diff: ", percentage_difference)
		
		# If purchase total != expected cost, you got the transaction wrong
		if purchase_total != expected_cost:
			print("Wrong fee")
			flag_bonus = false
		
		#Update loyalty based on difference between ammount demanded and ammount owed in increments of 5
		var delta_loyalty = -clamp(absolute_difference, -10, 10)
		if delta_loyalty >= 0:
			delta_loyalty += 0

		var loyalty_message = ""
		if flag_bad_transaction:
			delta_loyalty = -5
			message = lost_purchase_text[rng.randi() % lost_purchase_text.size()]
			loyalty_message = "Lost customer"
			flag_customer_refusal = true
			flag_bad_transaction = false
		elif purchase_total == 0 and expected_cost != 0:
			delta_loyalty = 10
			message = good_purchase_text[rng.randi() % good_purchase_text.size()]
			loyalty_message = "No charge"
		elif delta_loyalty > 0:
			delta_loyalty = 5
			message = good_purchase_text[rng.randi() % good_purchase_text.size()]
			loyalty_message = "Discount"
		elif delta_loyalty == -10:
			message = refusal_purchase_text[rng.randi() % refusal_purchase_text.size()]
			loyalty_message = "Refusal"
			flag_customer_refusal = true
		elif delta_loyalty < -5:
			delta_loyalty = -10
			message = ripoff_purchase_text[rng.randi() % ripoff_purchase_text.size()]
			loyalty_message = "Rip-off"
		elif delta_loyalty < 0:
			delta_loyalty = -5
			message = bad_purchase_text[rng.randi() % bad_purchase_text.size()]
			loyalty_message = "Overcharged"
		elif purchase_total == 0:
			message = return_text[rng.randi() % return_text.size()]

		change_loyalty(delta_loyalty, loyalty_message)
	
	customer.speech(message)
	
	if purchase_total != 0 and not flag_customer_refusal:
		money.create_bills(purchase_total)
	else:
		ui.set_total(0)
		
		# Want to give time for the speech bubble to show
		tween.interpolate_callback(self, 0.4, "customer_leave")
		tween.start()

func _on_Level_end_day():
	flag_end_day = true
	
func change_loyalty(change, message):
	if loyalty + change > 100:
		change = 100 - loyalty
	
	loyalty += change
	ui.update_loyalty_label(loyalty, message)
	
	if loyalty < 0:
		lose()

func change_cash(change, message):
	cash += change
	ui.update_cash_label(cash, message)
	
	if cash < bankrupt_cash:
		lose()

func increment_date():
	if cash >= win_cash and loyalty >= 100:
		win()
	else:
		# If they deserve a bonus queue give_bonus
		if flag_bonus:
			print("Deserves bonus")
			tween.interpolate_callback(self, 1, "give_bonus")
			tween.start()
		
		# Reset bonus to true each day
		flag_bonus = true
		
		current_day += 1
		if current_day > Global.month_length[current_month - 1]:
			current_day = 1
			current_month += 1
			if current_month > 12:
				current_month -= 12
		calendar.change_date(current_month, current_day)
		change_cash(-daily_fee, "Daily fee")
		ui.update_day_end(cash, loyalty)
		day_counter += 1

func give_bonus():
	print("Giving bonus")
	change_cash(10, "Bonus")	
	
func customer_leave():
	customer.exit()

func lose():
	print("You lose")
	pause_menu.end_game(false)

func win():
	print("You win")
	pause_menu.end_game(true)
