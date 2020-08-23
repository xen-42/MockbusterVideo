extends Area2D
class_name Register

var drawer_stowed_y = 14
var drawer_extended_y = 44

onready var tween = $Tween
onready var drawer = $register_drawer
onready var receipt = $receipt
onready var price_label = $PriceLabelNode2D/PriceLabel

var receipt_start = Vector2(-4.5, 11.5)
var receipt_end = Vector2(-4.5, -14.5)

var delta_t = 4
var delta_r = deg2rad(-33)

var drawer_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", self, "_on_Register_mouse_entered")
	connect("mouse_exited", self, "_on_Register_mouse_exited")

func _on_Register_mouse_entered():
	if Global.is_carrying_money:
		open_drawer()

func _on_Register_mouse_exited():
	if drawer_open:
		close_drawer()

func open_drawer():
	drawer_open = true
	tween.stop(drawer)
	tween.interpolate_property(drawer, "position",
		drawer.position, Vector2(0, drawer_extended_y),
		0.6, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	
	tween.start()
	SoundEffects.play("register.wav")

func close_drawer():
	drawer_open = false
	tween.stop(drawer)
	tween.interpolate_property(drawer, "position",
		drawer.position, Vector2(0, drawer_stowed_y),
		0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	tween.start()

func on_finish_transaction():
	receipt.rotation = 0
	tween.interpolate_property(receipt, "position",
		receipt_start, receipt_end, delta_t,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(receipt, "rotation",
		receipt.rotation, receipt.rotation + delta_r, delta_t,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(receipt, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), delta_t,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
	
	SoundEffects.play("receipt.wav")

func set_price_label(money):
	price_label.text = "%.2f" % money

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
