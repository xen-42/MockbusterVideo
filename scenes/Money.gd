extends Draggable

onready var tween = $Tween

# Used for counting money and displaying bills
var ammount = 0
var child_sprites = []

# Used for random placement of money pile
var rng = RandomNumberGenerator.new()

# Used to signal back to the game that money has been received
signal cash_signal(ammount)

# When moving into scene
var start_position = Vector2(537, 68)
var end_position = Vector2(537, 280)

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
	while i >= denomination:
		var new_sprite = Sprite.new()
		new_sprite.set_texture(texture)
		var pos_x = rng.randi()%30 - 15
		var pos_y = rng.randi()%30 - 15
		var rot = rng.randi()%-90
		new_sprite.set_position(Vector2(pos_x, pos_y))
		new_sprite.set_rotation(deg2rad(rot))
		
		self.add_child(new_sprite)
		child_sprites = child_sprites + [new_sprite]
		i -= denomination
	return i

func delete_bills():
	for s in child_sprites:
		s.queue_free()
	child_sprites = []
	self.ammount = 0
	self.set_position(Vector2(0,0))
	self.input_pickable = false

func _on_stop_drag():
	Global.is_carrying_money = false
	
	var bodies = self.get_overlapping_areas()
	if bodies.size() > 0:
		for body in bodies:
			if body is Register:
				print("Money put in register")
				emit_signal("cash_signal", ammount) #ammount is written in cents
				delete_bills()
				SoundEffects.play("money.wav")

func _on_start_drag():
	Global.is_carrying_money = true
