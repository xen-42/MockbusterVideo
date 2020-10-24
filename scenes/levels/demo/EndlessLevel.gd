extends Level

var week_number = 0

onready var scripted_customer = preload("res://scenes/customer/ScriptedCustomer.tscn")
onready var boss_body = preload("res://scenes/customer/Boss.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _start():
	if day_number == 0:
		var boss_intro = scripted_customer.instance()
		boss_intro.set_body_preset(boss_body)
		boss_intro.set_dialogue([
			"Hey bud.",
			"Another week of work, let's go."
		])
		next_customer(boss_intro)
	else:
		._start()

func _final_customer():
	._final_customer()
