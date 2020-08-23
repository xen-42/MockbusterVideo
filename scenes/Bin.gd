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
	
	Global.connect("enabled_changed", self, "_on_Global_enabled_changed")

func _on_Global_enabled_changed(type):
	# If a bin is only meant to serve invalid types just get rid of it
	if types.size() == 1 and types[0] == type:
		if not Global.enabled[type]:
			queue_free()

func _on_Bin_mouse_entered():
	pass

func _on_Bin_mouse_exited():
	pass
