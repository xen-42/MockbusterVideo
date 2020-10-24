extends Draggable

onready var tween = $Tween

# Used for counting money and displaying bills
var ammount = 0
var child_sprites = []
var child_materials = []

# Used for random placement of money pile
var rng = RandomNumberGenerator.new()

# Used to signal back to the game that money has been received
signal cash_signal(ammount)

# When moving into scene
var start_position = Vector2(167, 23)
var end_position = Vector2(167, 107)

# The textures for the money
var bill_20 = load("res://assets/money/bill_20.png")
var bill_10 = load("res://assets/money/bill_10.png")
var bill_5 = load("res://assets/money/bill_5.png")
var coin_2 = load("res://assets/money/coin_twoonie.png")
var coin_1 = load("res://assets/money/coin_loonie.png")
var coin_25 = load("res://assets/money/coin_quarter.png")
var coin_10 = load("res://assets/money/coin_dime.png")
var coin_5 = load("res://assets/money/coin_nickel.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

func make_pile(value):
	ammount = value
	var i = value
	i = add_bills(i, bill_20, 20)
	i = add_bills(i, bill_10, 10)
	i = add_bills(i, bill_5, 5)
	i = add_bills(i, coin_2, 2)
	i = add_bills(i, coin_1, 1)
	i = add_bills(i, coin_25, 0.25)
	i = add_bills(i, coin_10, 0.10)
	i = add_bills(i, coin_5, 0.05)
	
	#Evenly space the coins out in a circle
	var angle_spacing = 0
	if child_sprites.size() != 0:
		angle_spacing = 2 * PI / child_sprites.size()
	#var radius = clamp(4 * sqrt(child_sprites.size()), 8, 20)
	var radius = 20
	collision_shape.shape.radius = radius + 6
	
	for j in range(0, child_sprites.size()):
		var pos_r = radius * (pow(fmod(rng.randf(), 2), 1.0))
		var pos_theta = angle_spacing * j
		
		child_sprites[j].position = Vector2(pos_r * cos(pos_theta), pos_r * sin(pos_theta))

func create_bills(value):
	make_pile(value)
	
	self.input_pickable = true
	
	# Have the money come in from where the character will be standing
	tween.interpolate_property(self, "position",
		start_position, end_position, 1,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate",
		Color(1,1,1,0), Color(1,1,1,1), 1,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
	
func add_bills(i, texture, denomination):
	#Gotta pad the number else it falls apart when equating them for some reason
	while (i+0.001) >= denomination:
		var new_sprite = Sprite.new()
		new_sprite.set_texture(texture)

		var rot = rng.randi()%-90
		new_sprite.set_rotation(deg2rad(rot))
		
		var new_material = self.material.duplicate()
		new_material.set_shader_param("rotation", -deg2rad(rot))
		
		self.add_child(new_sprite)
		child_sprites = child_sprites + [new_sprite]
		child_materials = child_materials + [new_material]
		i -= denomination
		
	return i

func delete_bills():
	for s in child_sprites:
		s.queue_free()
	child_sprites = []
	child_materials = []
	self.ammount = 0
	self.set_position(Vector2(0,0))
	self.input_pickable = false

func _on_stop_drag():
	._on_stop_drag()
	for i in range(0, child_sprites.size()):
		child_sprites[i].material = null
		
	Global.is_carrying_money = false
	
	var bodies = self.get_overlapping_areas()
	if bodies.size() > 0:
		for body in bodies:
			if body is Register:
				emit_signal("cash_signal", ammount) #ammount is written in cents
				delete_bills()
				SoundEffects.play("money.wav")

func _on_start_drag():
	._on_start_drag()
	for i in range(0, child_sprites.size()):
		child_sprites[i].material = child_materials[i]
	
	Global.is_carrying_money = true
