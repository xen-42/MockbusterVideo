extends Level

onready var scripted_customer = preload("res://scenes/customer/ScriptedCustomer.tscn")
onready var boss_body = preload("res://scenes/customer/Boss.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _start():
	var boss_intro = scripted_customer.instance()
	boss_intro.set_body_preset(boss_body)
	boss_intro.set_dialogue([
		"Hey buddy, welcome to Mockbuster.",
		"I'm Daryl, the manager here.",
		"Anyway...",
		"For today you'll just be handling rentals.",
		"Customers will bring you the VHS tapes they want.",
		"All you have to do is put a STICKER with the due date on the VHS cover.",
		"Oh, and charge them for their number of rentals on the CLIPBOARD.",
		"Anyway, hope you got that.",
		"I'll check on you later."
	])
	next_customer(boss_intro)

func _final_customer():
	var boss_outro = scripted_customer.instance()
	boss_outro.set_body_preset(boss_body)
	boss_outro.set_dialogue([
		"Good work today.",
		"See you tomorrow."
	])
	next_customer(boss_outro)
