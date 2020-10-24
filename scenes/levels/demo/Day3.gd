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
		"Hey. Halfway through your first week, eh?",
		"So today we're upping you to sales.",
		"People buy the nice VHS's, like with nice covers. Not with generic Mockbuster covers.",
		"So if they got one of those, charge it as a SALE.",
		"Nice and easy. No stickers. No bins.",
		"We're also selling popcorn now.",
	])
	next_customer(boss_intro)

func _final_customer():
	var boss_outro = scripted_customer.instance()
	boss_outro.set_body_preset(boss_body)
	boss_outro.set_dialogue([
		"Closing time.",
		"You don't really say much, eh?",
		"I'll see you tomorrow."
	])
	next_customer(boss_outro)
