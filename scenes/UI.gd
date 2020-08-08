extends Node2D

var current_total = 0
#onready var total_label = $ColorRect/FeeOptions/TotalLabel
onready var fee_options = $ColorRect/FeeContainer/FeeOptions
onready var enter_button = $ColorRect/FeeContainer/EnterButton
onready var stocks_cash = $ColorRect/CashStocks
onready var stocks_loyalty = $ColorRect/LoyaltyStocks

onready var register_price_label = get_node("/root/Level/GameScene/Register/PriceLabelNode2D/PriceLabel")

signal complete_purchase(money)


func _ready():
	connect("complete_purchase", get_node("/root/Level"), "_on_Level_complete_purchase")

func set_total(money):
	current_total = money
	# For some reason money can be like, -0
	register_price_label.text = "%.2f" % abs(money)

func _on_UI_total_change(change):
	print("Total changed!")
	set_total(current_total + change)

func _on_EnterButton_button_down():
	enter_button.disabled = true
	emit_signal("complete_purchase", current_total)
	# Reset the fee options
	for c in fee_options.get_children():
		c.reset()
	$EnterButtonSound.play()

func update_cash_label(cash, message):
	stocks_cash.update_counter_label(cash, message)
	stocks_cash.add_daily_cash(cash)

func update_loyalty_label(loyalty, message):
	stocks_loyalty.update_counter_label(loyalty, message)
	stocks_loyalty.add_daily_cash(loyalty)

func update_day_end(cash, loyalty):
	pass

