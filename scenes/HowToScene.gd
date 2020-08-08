extends Node2D

onready var VCR = $CanvasLayer/ColorRect/Node2D/VCR
onready var calendar = $CanvasLayer/ColorRect/Node2D/Calendar
onready var node = $CanvasLayer/ColorRect/Node2D
onready var money = $CanvasLayer/ColorRect/Node2D/Register/Money
onready var register = $CanvasLayer/ColorRect/Node2D/Register

onready var tape1 = $CanvasLayer/ColorRect/Node2D/return
onready var tape2 = $CanvasLayer/ColorRect/Node2D/repair
onready var tape3 = $CanvasLayer/ColorRect/Node2D/trash

onready var cover1 = $CanvasLayer/ColorRect/Node2D/vhs_3/VHS_Cover_root2
onready var cover2 = $CanvasLayer/ColorRect/Node2D/vhs_4/VHS_Cover_root3

onready var register_price_label = $CanvasLayer/ColorRect/Node2D/Register/PriceLabelNode2D/PriceLabel

const VHS = preload("res://scenes/VHS_Pair.tscn")
var hidden_VHS = VHS.instance()

var vcr_timer = 0
var calendar_timer = 0
var money_timer = 0
var register_timer = 0

var current_day = 2
var current_month = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioServer.set_bus_mute(0,true)
	
	hidden_VHS.is_rewound = false
	hidden_VHS.has_cover = false
	hidden_VHS.position = Vector2(362, 100)
	hidden_VHS.rotation = -deg2rad(90)
	hidden_VHS.scale = Vector2(1,1)
	node.add_child(hidden_VHS)
	
	VCR.insert_vhs(hidden_VHS)
	money.make_pile(138.55)
	
	register_price_label.text = "%.2f" % 138.55


func _process(delta):
	vcr_timer += delta
	calendar_timer += delta
	money_timer += delta
	register_timer += delta
	
	money.position = Vector2(40 + 30 * cos(0.5 * PI * money_timer), money.position.y)
	tape1.position = Vector2(tape1.position.x, 155 - 4 * cos(0.5 * PI * money_timer))
	tape2.position = Vector2(tape2.position.x, 155 - 4 * cos(0.5 * PI * money_timer))
	tape3.position = Vector2(tape3.position.x, 155 - 4 * cos(0.5 * PI * money_timer))
	
	cover1.position = Vector2(0, 4 * cos(0.5 * PI * money_timer) - 4)
	cover2.position = Vector2(0, 4 * cos(0.5 * PI * money_timer) - 4)
	
	if money.position.x < 32 and not register.drawer_open:
		register.open_drawer()
	elif money.position.x > 32 and register.drawer_open:
		register.close_drawer()
	
	if calendar_timer > 5:
		current_day += 1
		if current_day > Global.month_length[current_month - 1]:
			current_day = 1
			current_month += 1
			if current_month > 12:
				current_month -= 12
		calendar.change_date(current_month, current_day)
		calendar_timer -= 5
	
	if vcr_timer > 3:
		hidden_VHS.is_rewound = false
		VCR.insert_vhs(hidden_VHS)
		vcr_timer -= 3

func _on_MenuButton_button_down():
	AudioServer.set_bus_mute(0,false)
	get_tree().change_scene("res://scenes/MainMenu.tscn")
