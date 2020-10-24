extends DemoLevel

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
		"Today you're going to start taking RETURNs.",
		"If the customer is giving you back a VHS with a due date on it, it's a RETURN.",
		"Just put them in the return bin under your desk.",
		"Oh, and be sure to check the date. If it's dated earlier than today, it's LATE.",
		"Your calendar has today's date on it.",
		"I mean... you know how calendars work yeah?",
	])
	next_customer(boss_intro)

func _final_customer():
	var boss_outro = scripted_customer.instance()
	boss_outro.set_body_preset(boss_body)
	boss_outro.set_dialogue([
		"Oh, by the way.",
		"People like discounts, yeah?",
		"So maybe from time to time, don't charge a LATE fee, you know?",
		"Or any fee really.",
		"We've been losing customers lately, so customer LOYALTY has been going down daily.",
		"Discounts ought to raise LOYALTY.",
		"People will buy more when LOYALTY is high.",
		"Although, then we lose our DAILY BONUS for not getting any orders wrong.",
		"Up to you."
	])
	next_customer(boss_outro)
