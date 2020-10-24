extends Node2D
class_name Level

var cash = Global.cash
var loyalty = Global.loyalty

export(int, 100) var _vhs = 0
export(int, 100) var _dvd = 0
export(int, 100) var _popcorn = 0
export(int, 100) var _return = 0
export(int, 100) var _rental = 0
export(int, 100) var _sale = 0
export(int, 100) var _normal = 0
export(int, 100) var _repair = 0
export(int, 100) var _trash = 0
export(int, 100) var _rewind = 0
export(int, 100) var _late = 0

export(int, 11) var current_month = 8
export(int, 31) var current_day = 22
export(int, 2000) var current_year = 1996
export(int, 8) var order_size = 6

var day_string = Global.day_string[0]

var fade_time = 2
onready var overlay = $Overlay
onready var overlay_label = $Overlay/ColorRect/Label
onready var overlay_tween = $Overlay/Tween

var paused = false

onready var ui = $UI
onready var transaction_button = $UI/ColorRect/FeeContainer/EnterButton
onready var money = $GameScene/Money
onready var calendar = $GameScene/Calendar
onready var register = $GameScene/Register
onready var clock = $GameScene/Clock
onready var sticker_stack = $GameScene/StickerStack

onready var sky = $GameScene/Window/Sky

onready var game_scene = $GameScene

onready var shader = $GameScene/ScreenShader/Shader
var customer = null

var treating_customer = false
var flag_customer_refusal = false
var flag_try_price_again = false
var flag_bad_transaction = false
var expected_cost = 0

var flag_bonus = true
var flag_end_day = false
var flag_outro_customer_finished = false

onready var customer_scene = preload("res://scenes/customer/Customer.tscn")
var rng = RandomNumberGenerator.new()

signal start_day
signal win
signal lose

const song = "game_theme.ogg"
const night_song = Global.night_song

var day_number = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not SoundEffects.is_playing(night_song):
		SoundEffects.play(night_song)
	
	rng.randomize()
	
	money.connect("cash_signal", self, "_on_Level_cash_signal")
	clock.connect("end_day", self, "_on_Level_end_day")
	connect("start_day", clock, "_on_Clock_start_day")
	
	ui.connect("complete_purchase", self, "_on_Level_complete_purchase")
	ui.connect("total_change", self, "_on_Level_total_change")
	connect("ready", ui, "_on_Level_ready")
	
	overlay_label.text = "%s\n%s %d, %d" % [day_string, Global.month_string[current_month-1], current_day, current_year]
	
	var yesterday = Global.day_calculator(current_day, current_month, current_year, -1)
	calendar.set_date(yesterday[0], yesterday[1])
	
	# Fade in
	overlay_tween.interpolate_property(overlay, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), fade_time,
		Tween.TRANS_EXPO, Tween.EASE_IN)
	overlay_tween.start()
	overlay_tween.interpolate_callback(self, fade_time + 1, "_start_day")
	
	var future_due_date = Global.day_calculator(current_day, current_month, current_year, 7)
	sticker_stack.set_date(future_due_date[0], future_due_date[1])
	
	Global.set_enabled(Global.ItemTypeEnum.VHS, _vhs != 0)
	Global.set_enabled(Global.ItemTypeEnum.DVD, _dvd != 0)
	Global.set_enabled(Global.ItemTypeEnum.POPCORN, _popcorn != 0)
	Global.set_enabled(Global.ItemTypeEnum.RETURN, _return != 0)
	Global.set_enabled(Global.ItemTypeEnum.RENTAL, _rental != 0)
	Global.set_enabled(Global.ItemTypeEnum.SALE, _sale != 0)
	Global.set_enabled(Global.ItemTypeEnum.NORMAL, _normal != 0)
	Global.set_enabled(Global.ItemTypeEnum.REPAIR, _repair != 0)
	Global.set_enabled(Global.ItemTypeEnum.TRASH, _trash != 0)
	Global.set_enabled(Global.ItemTypeEnum.REWIND, _rewind != 0)
	Global.set_enabled(Global.ItemTypeEnum.LATE, _late != 0)

func next_customer(new_customer):
	# Add new customer
	customer = new_customer
	if customer.freeze_time_while_talking:
		clock.stop_clock()
	else:
		clock.start_clock()
	
	if SoundEffects.is_playing(night_song):
		SoundEffects.fade_out(night_song, 3, true)
	
	game_scene.add_child(customer)
	
	customer.set_order(_vhs, _dvd, _popcorn, _return, _rental, _sale, _normal, _repair, _trash, _rewind, _late)
	customer.connect("customer_cleared", self, "_on_Level_customer_cleared")
	customer.connect("customer_ready", self, "_on_Level_customer_ready")
	customer.order.connect("new_item", self, "_on_Level_new_item")
	customer.order.connect("order_complete", self, "_on_Level_order_complete")
	
	customer.enter()
	
func _start_day():
	overlay.visible = false
	
	calendar.change_date(current_day, current_month)
	clock.start_clock()
	
	_start()

# To be overriden in other level types
func _start():
	next_customer(customer_scene.instance())

func fade_out():
	overlay.visible = true
	overlay_label.visible = false
	
	overlay_tween.interpolate_property(overlay, "modulate",
		Color(1,1,1,0), Color(1,1,1,1), fade_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	overlay_tween.start()
	overlay_tween.interpolate_callback(self, fade_time, "queue_free")

func _final_customer():
	# In general there won't be one so we just skip. Overwrite this on specific days
	end_day()

func end_day():
	if not flag_outro_customer_finished:
		flag_outro_customer_finished = true
		_final_customer()
	else:
		SoundEffects.fade_in(night_song, 1)
		
		if cash >= Global.win_cash and loyalty >= Global.win_loyalty:
			win()
		
		change_cash(Global.daily_fee, "Daily")
		change_loyalty(Global.daily_loyalty, "Daily")
		
		# If they deserve a bonus queue give_bonus
		if flag_bonus:
			change_cash(Global.daily_bonus, "Bonus")
		
		_end_day()
		
		ui.connect("UI_finished_updating", self, "fade_out")

# A function for overloading
func _end_day():
	pass

func _process(delta):
	var period = clock.seconds_per_hour * 12
	var y = -630+(sky.frames.get_frame("default", 0).get_size().y - 68) * (clock.time - (8 * clock.seconds_per_hour)) / period
	
	sky.position = Vector2(sky.position.x, y)
	
	shader.material.set_shader_param("time", clock.get_daylight())

func _on_Level_order_complete():
	transaction_button.disabled = false
	treating_customer = false

# When a new item is added
func _on_Level_new_item(item):
	item.connect("item_signal", self, "_on_Level_item_signal")

# After the customer has entered the scene
func _on_Level_customer_ready():
	# Lets make order_size tied to loyalty
	order_size = int(clamp(loyalty / (100.0 / 6.0), 1, 6))
	
	# Only want to increment the date when we're done with a customer	
	var expected_order = customer.order.create_order(current_month, current_day, order_size)
	
	var order_string = ""
	expected_cost = 0
	
	for i in Global.ItemTypeEnum.values():
		expected_cost += Global.prices[i] * expected_order[i]
		order_string += "%s: %d\t" % [Global.ItemTypeEnum.keys()[i], expected_order[i]]
	
	print("Expected order: ", order_string)
	print("Expected cost: ", expected_cost)
	treating_customer = true
	transaction_button.disabled = true

# After the current customer has left the scene
func _on_Level_customer_cleared():
	#Once the customer has left we either end the day or send in a new one
	if flag_end_day:
		end_day()
	else:
		next_customer(customer_scene.instance())

#After cash is put into the register
func _on_Level_cash_signal(ammount):
	change_cash(ammount, "")
	ui.set_total(0)
	register.on_finish_transaction()
	customer.exit()

func _on_Level_total_change(money):
	register.set_price_label(money)

# Happens when an item is placed in a bin
func _on_Level_item_signal(bin_types, item_types):
	var item_string = ""
	for i in item_types:
		item_string += Global.ItemTypeEnum.keys()[i] + " "
	
	var bin_string = ""
	for i in bin_types:
		bin_string += Global.ItemTypeEnum.keys()[i] + " "
	
	print("Received item type %sin bin type %s" % [item_string, bin_string])
	# Put logic for VHS stuff	
	# Special logic for giving the wrong thing to the customer
	if bin_types.has(Global.ItemTypeEnum.SALE):
		# Logic for stickered rentals
		if item_types.has(Global.ItemTypeEnum.RENTAL):
			if not item_types.has(Global.ItemTypeEnum.STICKERED):
				change_cash(-Global.prices[Global.ItemTypeEnum.STICKERED], "No sticker")
				flag_bonus = false
		# Giving away VHS
		if not item_types.has(Global.ItemTypeEnum.SALE) and not item_types.has(Global.ItemTypeEnum.RENTAL) and item_types.has(Global.ItemTypeEnum.VHS):
			customer.received_wrong_item()
			change_cash(-Global.prices[Global.ItemTypeEnum.SALE], "Gave away VHS")
			flag_bonus = false
	else:
		if not Global.array_intersect(bin_types, item_types):
			change_cash(-5, "Wrong bin")
			flag_bonus = false
		# Not giving VHS to customer
		if item_types.has(Global.ItemTypeEnum.SALE) or item_types.has(Global.ItemTypeEnum.RENTAL) or item_types.has(Global.ItemTypeEnum.POPCORN):
			customer.took_away_item()
			for t in item_types:
				expected_cost -= Global.prices[t]
				print("Subtracted %.2f from price: type %s", Global.prices[t], Global.ItemTypeEnum.keys()[t])
			flag_bad_transaction = true
			flag_bonus = false

# Happens after clicking enter button
func _on_Level_complete_purchase(purchase_total):
	var customer_reaction = customer.react_to_price(expected_cost, purchase_total, flag_bad_transaction)
	var delta_loyalty = 0
	var loyalty_message = ""
	# If the customer is going to give money
	var flag_charge_money = purchase_total != 0
	
	match(customer_reaction):
		Global.CustomerReaction.RETRY:
			# If they are aable to retry just end this function call
			return
		Global.CustomerReaction.DISCOUNT:
			delta_loyalty = 5
			loyalty_message = "Discount"
			flag_bonus = false
		Global.CustomerReaction.FREE:
			flag_charge_money = false
			delta_loyalty = 10
			loyalty_message = "Free"
			flag_bonus = false
		Global.CustomerReaction.OVERCHARGE:
			delta_loyalty = -5
			loyalty_message = "Overcharge"
			flag_bonus = false
		Global.CustomerReaction.REFUSE:
			flag_charge_money = false
			delta_loyalty = -10
			loyalty_message = "Refusal"
			flag_bonus = false
	ui.reset()
	change_loyalty(delta_loyalty, loyalty_message)
	
	if flag_charge_money:
		money.create_bills(purchase_total)
	else:
		ui.set_total(0)
		customer.exit()

func _on_Level_end_day():
	flag_end_day = true
	
func change_loyalty(change, message):
	if loyalty + change > 100:
		change = 100 - loyalty
	
	loyalty += change
	ui.update_loyalty_label(loyalty, message)
	
	Global.loyalty = loyalty
	
	if loyalty <= Global.lose_loyalty:
		lose()

func change_cash(change, message):
	cash += change
	ui.update_cash_label(cash, message)
	
	Global.cash = cash
	
	if cash <= Global.lose_cash:
		lose()

func lose():
	print("You lose")
	emit_signal("lose")

func win():
	print("You win")
	emit_signal("win")
