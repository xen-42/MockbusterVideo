extends Node2D

var rng = RandomNumberGenerator.new()

# The textures for the people
var bodies = [
	load("res://assets/people/body_0.png"),
	load("res://assets/people/body_1.png"),
	load("res://assets/people/body_2.png"),
	load("res://assets/people/body_3.png")
]

var ears = [
	load("res://assets/people/ears_0.png"),
	load("res://assets/people/ears_1.png"),
	load("res://assets/people/ears_2.png")
]

var hairs = [
	load("res://assets/people/hair_0.png"),
	load("res://assets/people/hair_1.png"),
	load("res://assets/people/hair_2.png"),
	load("res://assets/people/hair_3.png"),
	load("res://assets/people/hair_4.png")
]

var heads = [
	load("res://assets/people/head_0.png"),
	load("res://assets/people/head_1.png"),
	load("res://assets/people/head_2.png"),
	load("res://assets/people/head_3.png")
]

var eyes = [
	load("res://assets/people/eyes_0.png"),
	load("res://assets/people/eyes_1.png"),
	load("res://assets/people/eyes_2.png"),
	load("res://assets/people/eyes_3.png")
]

var skin_tones = [
	colour(255, 220, 177),
	colour(229, 194, 152),
	colour(217, 145, 100),
	colour(56, 0, 0),
	colour(253, 228, 200),
	colour(187, 109, 74),
	colour(222, 171, 127),
	colour(224, 177, 132),
	colour(91, 0, 0),
	colour(189, 151, 120)
]

var hair_tones = [
	colour(90, 39, 41),
	colour(118, 57, 40),
	colour(145, 85, 77),
	colour(126, 46, 31),
	colour(165, 113, 78),
	colour(133, 87, 35),
	colour(213, 198, 161),
	colour(24, 61, 97),
	colour(87, 65, 47),
	colour(121, 96, 67),
	Color(0, 0, 0, 0) #Bald
]

var start_position = Vector2(-150, 156)
var mid_position = Vector2(500, 156)
var end_position = Vector2(1400, 156)

func colour(r, g, b):
	return Color(r / 255.0, g / 255.0, b / 255.0)

onready var body_sprite = $BodySprite
onready var head_sprite = $HeadSprite
onready var hair_sprite = $HeadSprite/HairSprite
onready var ear_sprite = $HeadSprite/EarsSprite
onready var eye_sprite = $HeadSprite/EyesSprite
onready var glasses_sprite = $HeadSprite/GlassesSprite

onready var tween = $Tween
onready var head_tween = $HeadSprite/HeadTween
var enter_time = 1.2
var exit_time = 0.8

signal customer_cleared
signal customer_ready

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	reset()
	connect("customer_cleared", get_node("/root/Level"), "_on_Level_customer_cleared")
	connect("customer_ready", get_node("/root/Level"), "_on_Level_customer_ready")

	

func randomize_character():
	body_sprite.texture = bodies[rng.randi() % bodies.size()]
	body_sprite.self_modulate = Color(rng.randf_range(0.1, 1), rng.randf_range(0.1,1), rng.randf_range(0.1,1))
	
	hair_sprite.texture = hairs[rng.randi() % hairs.size()]
	hair_sprite.self_modulate = hair_tones[rng.randi() % hair_tones.size()]
	
	var skin_tone = skin_tones[rng.randi() % skin_tones.size()]
	
	ear_sprite.texture = ears[rng.randi() % ears.size()]
	head_sprite.texture = heads[rng.randi() % heads.size()]
	ear_sprite.self_modulate = skin_tone
	head_sprite.self_modulate = skin_tone
	
	eye_sprite.texture = eyes[rng.randi() % eyes.size()]
	
	if rng.randi() % 3 != 1:
		glasses_sprite.visible = false

func enter():
	tween.interpolate_property(self, "position",
		self.position, mid_position, enter_time,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_callback(self, enter_time, "customer_ready")
	tween.start()

func customer_ready():
	emit_signal("customer_ready")

func exit():
	tween.interpolate_property(self, "position",
		self.position, end_position, exit_time,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_callback(self, exit_time, "reset")
	tween.start()

func reset():
	self.position = start_position
	randomize_character()
	emit_signal("customer_cleared")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
