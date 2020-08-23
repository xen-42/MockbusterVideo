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
		"Hey. So it seems some people aren't treating our rentals too well.",
		"God people bringing back VHS's with the tape falling out.",
		"That's not too bad. That can be repaired",
		"Some other ones though? They got full chunks taken out of the casette.",
		"Like, how do they even manage that?",
		"Basically, if it's minor, tape hanging out, put it in the repair bin and charge it as a repair.",
		"But the really broken ones? Trash bin. And charge them as a sale.",
		"They broke the tape, they can buy it."
	])
	next_customer(boss_intro)

func _final_customer():
	end_day()
