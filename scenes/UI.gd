extends Node2D

var current_total = 0

var current_page = 0
var number_of_pages = 1

const number_per_page = 4
const y_spacing = 72

const fee_ui = preload("res://scenes/FeeUI.tscn")

onready var register_price_label = get_node("/root/Level/GameScene/Register/PriceLabelNode2D/PriceLabel")
onready var fee_options = $ColorRect/FeeContainer/FeeOptions
onready var enter_button = $ColorRect/FeeContainer/EnterButton
onready var stocks_cash = $ColorRect/CashStocks
onready var stocks_loyalty = $ColorRect/LoyaltyStocks

onready var left_button = $ColorRect/FeeContainer/LeftButton
onready var right_button = $ColorRect/FeeContainer/RightButton

var pages = []

signal complete_purchase(money)


func _ready():
	connect("complete_purchase", get_node("/root/Level"), "_on_Level_complete_purchase")
	
	var page = []
	var counter = 0
	var first_page = true
	for i in Global.ItemTypeEnum.values():
		if Global.ui_enabled[i]:
			if counter > number_per_page - 1:
				number_of_pages += 1
				counter = 0
				pages.append(page)
				page = []
			
			var fee = fee_ui.instance()
			fee.fee_type = i
			fee.position = Vector2(14, 84 + counter * y_spacing)
			fee.visible = false
			fee_options.add_child(fee)
			page.append(fee)
			counter += 1
	pages.append(page)
	
	set_page(0)

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
	SoundEffects.play("click.wav")

func update_cash_label(cash, message):
	stocks_cash.update_counter_label(cash, message)
	stocks_cash.add_daily_cash(cash)

func update_loyalty_label(loyalty, message):
	stocks_loyalty.update_counter_label(loyalty, message)
	stocks_loyalty.add_daily_cash(loyalty)

func update_day_end(cash, loyalty):
	pass

func set_page(page_number):
	for i in pages[current_page]:
		i.visible = false
	current_page = page_number
	for i in pages[current_page]:
		i.visible = true
	
	print("%d %d" % [current_page, number_of_pages])

	
	left_button.visible = current_page != 0
	right_button.visible = current_page != number_of_pages - 1

func _on_RightButton_button_down():
	set_page(current_page + 1)

func _on_LeftButton_button_down():
	set_page(current_page - 1)
