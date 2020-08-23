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
		"Hey, how are you?",
		"Today you're going to start taking returns.",
		"If the customer is giving you back a VHS it's a return.",
		"Just put them in the return bin under your desk.",
		"Oh, and be sure to check the date. If it's dated earlier than today, it's late.",
		"Your calendar has today's date on it. I mean... you know how calendars work yeah?",
		"Okay cool. That should be it.",
		"Um... Yeah. See ya."
	])
	next_customer(boss_intro)

func _final_customer():
	end_day()
