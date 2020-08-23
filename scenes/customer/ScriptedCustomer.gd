extends Customer

var dialogue_counter = 0
var dialogue = [""]

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("finished_talking", self, "_on_ScriptedCustomer_finished_talking")

func set_dialogue(d):
	dialogue = d

# Overwritten so we can have custom behaviour when the character arrives
func customer_ready():
	speech(dialogue[dialogue_counter])

func _on_ScriptedCustomer_finished_talking():
	print("done talking")
	dialogue_counter += 1
	if dialogue_counter < dialogue.size():
		speech(dialogue[dialogue_counter])
	else:
		speech_tween.interpolate_callback(self, speech_time, "exit")
		speech_tween.start()
