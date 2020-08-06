extends Area2D

var drawer_stowed_y = 14
var drawer_extended_y = 44

onready var tween = $Tween
onready var drawer = $register_drawer

var drawer_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", self, "_on_Register_mouse_entered")
	connect("mouse_exited", self, "_on_Register_mouse_exited")

func _on_Register_mouse_entered():
	if Global.is_carrying_money:
		drawer_open = true
		tween.stop(drawer)
		tween.interpolate_property(drawer, "position",
			drawer.position, Vector2(0, drawer_extended_y),
			0.6, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		
		tween.start()

func _on_Register_mouse_exited():
	if drawer_open:
		drawer_open = false
		tween.stop(drawer)
		tween.interpolate_property(drawer, "position",
			drawer.position, Vector2(0, drawer_stowed_y),
			0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
		
		tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
