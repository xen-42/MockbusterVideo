extends Area2D
class_name Bin

export var texture = preload("res://assets/bin_returns.png")

export(Array, Global.ItemTypeEnum) var types = []

onready var bin_sprite = $BinSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	bin_sprite.texture = texture
	connect("mouse_entered", self, "_on_Bin_mouse_entered")
	connect("mouse_exited", self, "_on_Bin_mouse_exited")

func _on_Bin_mouse_entered():
	pass

func _on_Bin_mouse_exited():
	pass
