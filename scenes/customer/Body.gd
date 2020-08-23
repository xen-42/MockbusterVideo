tool
extends Node2D

export var randomized = true setget set_randomized

onready var tween = $BobTween
onready var body_sprite = $BodySprite
onready var head_sprite = $HeadSprite
onready var hair_sprite = $HairSprite
onready var ear_sprite = $EarsSprite
onready var eye_sprite = $EyesSprite
onready var nose_sprite = $NoseSprite

export(Color) var shirt_colour = Color(1, 1, 1) setget set_shirt
export(float, 0.9, 1.5) var pitch = 1.0

var tween_values = [0, 3]

var rng = RandomNumberGenerator.new()

# The textures for the people
const bodies = [
	preload("res://assets/people/body_0.png"),
	preload("res://assets/people/body_1.png"),
	preload("res://assets/people/body_2.png"),
	preload("res://assets/people/body_3.png")
]
export(int, 0, 3) var body_choice = 0 setget set_body

const ears = [
	preload("res://assets/people/ears_0.png"),
	preload("res://assets/people/ears_1.png"),
	preload("res://assets/people/ears_2.png")
]
export(int, 0, 2) var ear_choice = 0 setget set_ear

const hairs = [
	preload("res://assets/people/hair_0.png"),
	preload("res://assets/people/hair_1.png"),
	preload("res://assets/people/hair_2.png"),
	preload("res://assets/people/hair_3.png"),
	preload("res://assets/people/hair_4.png"),
	preload("res://assets/people/hair_5.png")
]
export(int, 0, 5) var hair_choice = 0 setget set_hair

const heads = [
	preload("res://assets/people/head_0.png"),
	preload("res://assets/people/head_1.png"),
	preload("res://assets/people/head_2.png"),
	preload("res://assets/people/head_3.png")
]
export(int, 0, 3) var head_choice = 0 setget set_head

const eyes = [
	preload("res://assets/people/eyes_0.png"),
	preload("res://assets/people/eyes_1.png"),
	preload("res://assets/people/eyes_2.png"),
	preload("res://assets/people/eyes_3.png")
]
export(int, 0, 3) var eye_choice = 0 setget set_eye

const noses = [
	preload("res://assets/people/nose_0.png"),
	preload("res://assets/people/nose_1.png"),
	preload("res://assets/people/nose_2.png"),
	preload("res://assets/people/nose_3.png")
]
export(int, 0, 3) var nose_choice = 0 setget set_nose

const skin_tones = [
	[255, 220, 177, 255],
	[229, 194, 152, 255],
	[217, 145, 100, 255],
	[56, 0, 0, 255],
	[253, 228, 200, 255],
	[187, 109, 74, 255],
	[222, 171, 127, 255],
	[224, 177, 132, 255],
	[91, 0, 0, 255],
	[189, 151, 120, 255]
]
export(int, 0, 9) var skin_choice = 0 setget set_skin

const hair_tones = [
	[90, 39, 41, 255],
	[118, 57, 40, 255],
	[145, 85, 77, 255],
	[126, 46, 31, 255],
	[165, 113, 78, 255],
	[133, 87, 35, 255],
	[213, 198, 161, 255],
	[24, 61, 97, 255],
	[87, 65, 47, 255],
	[121, 96, 67, 255],
	[0, 0, 0, 0] #Bald
]
export(int, 0, 10) var hair_tone_choice = 0 setget set_hair_tone

func _colour(rgba):
	return Color(rgba[0] / 255.0, rgba[1] / 255.0, rgba[2] / 255.0, rgba[3] / 255.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	create_body()
	_start_bob()

func _start_bob():
	tween.interpolate_property(
		self, "position", 
		Vector2(0,tween_values[0]), Vector2(0,tween_values[1]), 2.0, 
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	tween.start()

func _on_BobTween_tween_completed(object, key):
	tween_values.invert()
	_start_bob()

func create_body():
	if randomized:
		print("Randomized")
		body_choice = rng.randi() % bodies.size()
		shirt_colour = Color(rng.randf_range(0.1, 1), rng.randf_range(0.1,1), rng.randf_range(0.1,1))
		
		hair_choice = rng.randi() % hairs.size()
		hair_tone_choice = rng.randi() % hair_tones.size()
		
		skin_choice = rng.randi() % skin_tones.size()
		
		ear_choice = rng.randi() % ears.size()
		head_choice = rng.randi() % heads.size()
		nose_choice = rng.randi() % noses.size()
		eye_choice = rng.randi() % eyes.size()
		pitch = rng.randf_range(0.9, 1.5)
	
	body_sprite.texture = bodies[body_choice]
	body_sprite.self_modulate = shirt_colour
	
	hair_sprite.texture = hairs[hair_choice]
	hair_sprite.self_modulate = _colour(hair_tones[hair_tone_choice])
	
	var skin_tone = _colour(skin_tones[skin_choice])
	
	ear_sprite.texture = ears[ear_choice]
	head_sprite.texture = heads[head_choice]
	nose_sprite.texture = noses[nose_choice]
	
	ear_sprite.self_modulate = skin_tone
	head_sprite.self_modulate = skin_tone
	nose_sprite.self_modulate = skin_tone
	
	eye_sprite.texture = eyes[eye_choice]

func set_body(choice):
	body_choice = choice
	if Engine.editor_hint:
		create_body()

func set_ear(choice):
	ear_choice = choice
	if Engine.editor_hint:
		create_body()

func set_hair(choice):
	hair_choice = choice
	if Engine.editor_hint:
		create_body()

func set_head(choice):
	head_choice = choice
	if Engine.editor_hint:
		create_body()

func set_eye(choice):
	eye_choice = choice
	if Engine.editor_hint:
		create_body()

func set_nose(choice):
	nose_choice = choice
	if Engine.editor_hint:
		create_body()

func set_skin(choice):
	skin_choice = choice
	if Engine.editor_hint:
		create_body()

func set_hair_tone(choice):
	hair_tone_choice = choice
	if Engine.editor_hint:
		create_body()

func set_shirt(choice):
	shirt_colour = choice
	if Engine.editor_hint:
		create_body()

func set_randomized(b):
	randomized = b
	if Engine.editor_hint:
		create_body()
