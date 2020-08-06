extends Node2D

var current_total = 0
#onready var total_label = $ColorRect/FeeOptions/TotalLabel
onready var fee_options = $ColorRect/FeeContainer/FeeOptions
onready var enter_button = $ColorRect/FeeContainer/EnterButton
onready var stocks_cash = $ColorRect/CashStocks
onready var stocks_loyalty = $ColorRect/LoyaltyStocks

onready var cash_label = $ColorRect/CashLabel
onready var loyalty_label = $ColorRect/LoyaltyLabel

onready var register_price_label = get_node("/root/Level/Register/PriceLabelNode2D/PriceLabel")

signal complete_purchase(money)

var cash_warning_threshold = 20
var cash_danger_threshold = 0

var loyalty_warning_threshold = 50
var loyalty_danger_threshold = 20

var good_colour = Color(0, 0.9, 0, 1)
var warning_colour = Color(1, 0.5, 0, 1)
var danger_colour = Color(1, 0, 0, 1)

func _ready():
	connect("complete_purchase", get_node("/root/Level"), "_on_Level_complete_purchase")

func set_total(money):
	current_total = money
	#total_label.text = "$%.2f" % money
	register_price_label.text = "%.2f" % money

func _on_UI_total_change(change):
	print("Total changed!")
	set_total(current_total + change)

func _on_EnterButton_button_down():
	enter_button.disabled = true
	emit_signal("complete_purchase", current_total)
	# Reset the fee options
	for c in fee_options.get_children():
		c.reset()

func update_cash_label(cash):
	if cash < 0:
		cash_label.text = "-$%.2f" % -cash
	else:
		cash_label.text = "$%.2f" % cash
	
	if cash < cash_warning_threshold:
		cash_label.add_color_override("font_color", warning_colour)
	elif cash < cash_danger_threshold:
		cash_label.add_color_override("font_color", danger_colour)
	else:
		cash_label.add_color_override("font_color", good_colour)

func update_loyalty_label(loyalty):
	loyalty_label.text = "%d" % loyalty
	
	if loyalty < loyalty_warning_threshold:
		loyalty_label.add_color_override("font_color", warning_colour)
	elif loyalty < loyalty_danger_threshold:
		loyalty_label.add_color_override("font_color", danger_colour)
	else:
		loyalty_label.add_color_override("font_color", good_colour)

func update_day_end(cash, loyalty):
	stocks_cash.add_daily_cash(cash)
	stocks_loyalty.add_daily_cash(loyalty)
