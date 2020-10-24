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
		"So you may have noticed the new setup on your desk.",
		"New company policy. Be kind, REWIND.",
		"People are tired of renting a VHS, popping it in the VCR, and having it start halfway through the movie.",
		"People gotta REWIND their tapes now before they bring them in.",
		"So basically, when you get a regular RETURN:",
		"1. DOUBLE-CLICK to remove the cover.",
		"2. Put the VHS into the VCR.",
		"3. If the tape starts rewinding, then charge them the new REWIND fee.",
		"Otherwise, um, 4. Don't charge a REWIND fee.",
		"That should be it.",
		"Cool."
	])
	next_customer(boss_intro)

func _final_customer():
	var boss_outro = scripted_customer.instance()
	boss_outro.set_body_preset(boss_body)
	boss_outro.set_dialogue([
		"Hey! So you did pretty well your first week.",
		"Here on out theres no new things to learn.",
		"Just endless waves of customers. Forever.",
		"Assuming you don't let LOYALTY drop to %d." % Global.lose_loyalty,
		"Or let CASH drop below -$%d." % abs(Global.lose_cash),
		"That would be bad. We'd probably go out of business.",
		"But I bet if CASH was over $%d and LOYALTY was at %d..." % [Global.win_cash, Global.win_loyalty],
		"Why, we'd probably secure the future of Mockbuster Video forever.",
		"Anyway, it's late. See you next week."
	])
	next_customer(boss_outro)
