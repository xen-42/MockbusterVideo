extends Node2D
class_name Customer

export var freeze_time_while_talking = false

# The dialogue options
var give_away_vhs_text = [
	"Um... I didn't ask for this.",
	"Why did you give me this?",
	"I guess I'll take this"
]
var took_away_vhs_text = [
	"Hey I wanted that!",
	"Huh?",
	"What?"
]
var lost_purchase_text = [
	"I'm taking my business elsewhere...",
	"I'm not shopping here anymore..."
]
var ambivalent_purchase_text = [
	"Have a good day.",
	"Understandable. Have a nice day.",
	"Thank you.",
	"Mhm.",
	"Right.",
	"Cheers."
]
var return_text = [
	"Thanks.",
	"See you later."
]
var good_purchase_text = [
	"Thanks!",
	"Thanks for the discount!",
	"Thank you very cool.",
	"Oh, nice."
]
var bad_purchase_text = [
	"That seems expensive...",
	"Are you sure that's the price?",
	"If you say so...",
	"Pricey..."
]
var ripoff_purchase_text = [
	"What a rip-off!",
	"I'm not shopping here again...",
	"Uh, okay."
]
var refusal_purchase_text = [
	"I'm not paying that!",
	"No way!",
	"What? No?"
]
var wrong_price_text = [
	"Are you sure that's the price?",
	"Really? It costs that much?",
	"I don't think thats the price..."
]
var greeting_text = [
	"Hey.",
	"Hi.",
	"Just this.",
	"Hey how's it going?"
]
var bad_transaction_text = [
	"Um... Okay?",
	"Um... What?"
]

var start_position = Vector2(-50, 60)
var mid_position = Vector2(167, 60)
var end_position = Vector2(467, 60)

onready var tween = $Tween
var enter_time = 1.2
var exit_time = 0.8

signal customer_cleared
signal customer_ready
signal finished_talking

onready var body = $Body
onready var speech_label = $SpeechBubble/Control/Label
onready var speech_bubble = $SpeechBubble
onready var speech_tween = $SpeechBubble/SpeechTween
onready var characters_tween = $SpeechBubble/CharactersTween
onready var order = $Order

var speech_time = 1
var speech_fade_time = 0.6

var text_counter = 0
var line_counter = 0
var line_lengths = []

var hidden_character_count = 0
var character_time = 0.05
var pause_time = 0.07

var speech_bubble_scale = null
var speech_bubble_width = 100
var speech_bubble_start_position = null
var speech_bubble_end_position = null

# If the player should try asking the price again
var flag_try_price_again = true

# Want to make sure they finish speaking before leaving
var _is_talking = false
var _flag_exit = false

var rng = RandomNumberGenerator.new()

var _body_preset = null
var is_dialogue = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	self.position = start_position
	speech_bubble.visible = false
	
	if _body_preset != null:
		_replace_body()
	
	speech_bubble_scale = speech_bubble.scale
	speech_bubble_end_position = speech_bubble.position
	speech_bubble_start_position = Vector2(speech_bubble_end_position.x + speech_bubble_width, speech_bubble_end_position.y)

func set_body_preset(preset):
	_body_preset = preset
	if body != null:
		_replace_body()

func _replace_body():
	remove_child(body)
	var new_body = _body_preset.instance()
	body = new_body
	add_child(body)

func set_order(vhs, dvd, popcorn, return_, rental, sale, normal, repair, trash, rewind, late):
	order.VHS_likelihood = vhs
	order.DVD_likelihood = dvd
	order.popcorn_likelihood = popcorn
	order.return_likelihood = return_
	order.rental_likelihood = rental
	order.purchase_likelihood = sale
	order.normal_likelihood = normal
	order.repair_likelihood = repair
	order.trash_likelihood = trash
	order.rewind_likelihood = rewind
	order.late_likelihood = late

func enter():
	speech_bubble.visible = false
	tween.interpolate_property(self, "position",
		self.position, mid_position, enter_time,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_callback(self, enter_time, "customer_ready")
	tween.start()
	SoundEffects.play("walk.wav")

func customer_ready():
	#Have customer say something when entering
	speech(greeting_text[rng.randi() % greeting_text.size()])
	
	emit_signal("customer_ready")

func exit():
	# If they're talking queue them up to exit
	if _is_talking:
		_flag_exit = true
	else:
		# Get rid of them
		_flag_exit = false
		tween.interpolate_property(self, "position",
			self.position, end_position, exit_time,
			Tween.TRANS_QUAD, Tween.EASE_IN)
		tween.interpolate_callback(self, exit_time, "reset")
		tween.start()
		#SoundEffects.play("walk.wav")

func reset():
	characters_tween.stop(self)
	emit_signal("customer_cleared")
	queue_free()

func speech(message, dialogue = false):
	speech_tween.stop(self)
	
	# Reset the last messages
	text_counter = 0
	line_counter = 0
	line_lengths = []
	hidden_character_count = 0
	
	speech_label.set_visible_characters(0)
	speech_label.lines_skipped = 0
	
	# stop revealing letters if its already over
	characters_tween.stop(self)
	
	var width = speech_label.get_rect().size.x * speech_label.rect_scale.x
	var wrapped_text = Global.word_wrap(message, speech_label.get_font("SimpleFont"), width)
	var last_length = wrapped_text.length()
	
	for i in range(0, wrapped_text.count("\n")):
		var next_length = wrapped_text.left(last_length).find_last("\n")
		line_lengths.insert(0, next_length)
		last_length = next_length
	
	_is_talking = true
	speech_bubble.visible = true
	speech_label.text = wrapped_text
	
	if not is_dialogue:
		speech_label.lines_skipped = 0
		speech_bubble.scale = Vector2(0, speech_bubble.scale.y)
		speech_tween.interpolate_property(speech_bubble, "scale",
			Vector2(0, speech_bubble.scale.y), speech_bubble_scale, speech_fade_time,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT
		)
		speech_bubble.position = speech_bubble_start_position
		speech_tween.interpolate_property(speech_bubble, "position",
			speech_bubble_start_position, speech_bubble_end_position, speech_fade_time,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT
		)
	
	is_dialogue = dialogue
	
	_show_text_character()
	
	speech_tween.start()

func _show_text_character():
	# When switching dialogue the text counter can go over the size of the thing
	# For some reason godot doesnt count newlines or spaces
	var visible_characters = max(1 + text_counter - hidden_character_count - speech_label.text.count(" ", hidden_character_count, text_counter) - line_counter, 0)
	
	if text_counter < speech_label.text.length():
		speech_label.set_visible_characters(visible_characters)
		var c = speech_label.text[text_counter].to_lower()
		text_counter += 1
		
		if Global.is_character(c):
			SoundEffects.play("%c.wav" % c, body.pitch)
		
		if c == " " or c == "." or c == "!" or c == "?":
			characters_tween.interpolate_callback(self, pause_time, "_show_text_character")
		else:
			characters_tween.interpolate_callback(self, character_time, "_show_text_character")
		
		characters_tween.start()
		
		# Want to scroll only if its not all going to fit
		if c == "\n":
			line_counter += 1
			if line_counter > 2:
				speech_label.lines_skipped += 1
				hidden_character_count = line_lengths[line_counter - 3]
				# For some reason godot doesnt count newlines or spaces
				visible_characters = max(1 + text_counter - hidden_character_count - speech_label.text.count(" ", hidden_character_count, text_counter) - line_counter, 0)
				speech_label.set_visible_characters(visible_characters)
	else:
		speech_label.set_visible_characters(-1)
		speech_tween.interpolate_callback(self, speech_time, "_stop_talking")
		speech_tween.start()

func _stop_talking():
	_is_talking = false
	if not is_dialogue:
		speech_fade()
	
	emit_signal("finished_talking")
	if _flag_exit:
		speech_tween.interpolate_callback(self, speech_time, "exit")
		speech_tween.start()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# Skip current dialogue
			if is_dialogue:
				_stop_talking()
				speech_tween.stop(self)

func speech_fade():
	if not _is_talking:
		speech_tween.stop(self)
		
		speech_tween.interpolate_property(speech_bubble, "scale",
			speech_bubble_scale, Vector2(0, speech_bubble.scale.y), speech_fade_time / 2.0,
			Tween.TRANS_QUAD, Tween.EASE_OUT
		)
		speech_tween.interpolate_property(speech_bubble, "position",
			speech_bubble_end_position, speech_bubble_start_position, speech_fade_time / 2.0,
			Tween.TRANS_QUAD, Tween.EASE_OUT
		)

func received_wrong_item():
	speech(give_away_vhs_text[rng.randi() % give_away_vhs_text.size()])

func took_away_item():
	speech(took_away_vhs_text[rng.randi() % took_away_vhs_text.size()])

func get_random_entry(array):
	return array[rng.randi() % array.size()]

# return true if they accept it, false if they don't
func react_to_price(expected_price, demanded_price, flag_bad_transaction):
	# Tell them to retry
	var message = get_random_entry(ambivalent_purchase_text)
	var reaction = Global.CustomerReaction.ACCEPT
	
	# Precision really sucks here (round to nearest nickel)
	expected_price = stepify(expected_price, 0.05)
	demanded_price = stepify(demanded_price, 0.05)
	
	if demanded_price > expected_price and flag_try_price_again:
		message = get_random_entry(wrong_price_text)
		reaction = Global.CustomerReaction.RETRY
		flag_try_price_again = false
	else:	
		# If it's given away for free
		if demanded_price != expected_price:
			var absolute_difference = demanded_price - expected_price
			
			if absolute_difference > 10:
				message = get_random_entry(refusal_purchase_text)
				reaction = Global.CustomerReaction.REFUSE
			elif absolute_difference > 0:
				message = get_random_entry(ripoff_purchase_text)
				reaction = Global.CustomerReaction.OVERCHARGE
			elif demanded_price == 0 and expected_price != 0:
				# Given away for free
				message = get_random_entry(good_purchase_text)
				reaction = Global.CustomerReaction.FREE
			elif absolute_difference < 0:
				message = get_random_entry(good_purchase_text)
				reaction = Global.CustomerReaction.DISCOUNT
		elif expected_price == 0:
			message = get_random_entry(return_text)
			reaction = Global.CustomerReaction.ACCEPT
		#If its a bad transaction just change the message (unless its a retry)
		if flag_bad_transaction:
			message = get_random_entry(bad_transaction_text)
	
	speech(message)
	return reaction
