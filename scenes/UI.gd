extends Node2D

var current_total = 0

var current_page = 0
var number_of_pages = 1

const number_per_page = 4
const y_spacing = 30

const fee_ui = preload("res://scenes/FeeUI.tscn")

onready var fee_options = $ColorRect/FeeContainer/FeeOptions
onready var enter_button = $ColorRect/FeeContainer/EnterButton
onready var stocks_cash = $ColorRect/CashStocks
onready var stocks_loyalty = $ColorRect/LoyaltyStocks

onready var left_button = $ColorRect/FeeContainer/LeftButton
onready var right_button = $ColorRect/FeeContainer/RightButton

var pages = []

signal complete_purchase(money)
signal total_change(change)

signal UI_finished_updating

func _ready():
	stocks_loyalty.connect("update_value_done", self, "_on_Loyalty_update_value_done")
	stocks_cash.connect("update_value_done", self, "_on_Cash_update_value_done")
	pass

func _on_Level_ready():
	var page = []
	var counter = 0
	var first_page = true
	for i in Global.ItemTypeEnum.values():
		if Global.enabled[i] and Global.prices[i] > 0:
			if counter > number_per_page - 1:
				number_of_pages += 1
				counter = 0
				pages.append(page)
				page = []
			
			var fee = fee_ui.instance()
			fee.fee_type = i
			fee.position = Vector2(0, counter * y_spacing)
			fee.visible = false
			fee.connect("fee_change", self, "_on_UI_fee_change")
			fee_options.add_child(fee)
			page.append(fee)
			counter += 1
	pages.append(page)
	
	set_page(0)
	
	update_cash_label(Global.cash, "")
	update_loyalty_label(Global.loyalty, "")

func set_total(money):
	current_total = money
	emit_signal("total_change", current_total)

func reset():
	set_total(0)
	for c in fee_options.get_children():
		c.reset()
	enter_button.disabled = true

func _on_UI_fee_change(change):
	print("Total changed!")
	set_total(current_total + change)

func _on_EnterButton_button_down():
	emit_signal("complete_purchase", current_total)
	SoundEffects.play("click.wav")

func set_page(page_number):
	for i in pages[current_page]:
		i.visible = false
	current_page = page_number
	for i in pages[current_page]:
		i.visible = true
	
	left_button.visible = current_page != 0
	right_button.visible = current_page != number_of_pages - 1

func _on_RightButton_button_down():
	set_page(current_page + 1)

func _on_LeftButton_button_down():
	set_page(current_page - 1)

func update_cash_label(cash, message):
	stocks_cash.update_value(cash, message)

func update_loyalty_label(loyalty, message):
	stocks_loyalty.update_value(loyalty, message)

func _on_Loyalty_update_value_done():
	# Everything will be done updating if the other stock is also done updating
	if not stocks_cash.is_updating:
		emit_signal("UI_finished_updating")

func _on_Cash_update_value_done():
	# Everything will be done updating if the other stock is also done updating
	if not stocks_loyalty.is_updating:
		emit_signal("UI_finished_updating")
