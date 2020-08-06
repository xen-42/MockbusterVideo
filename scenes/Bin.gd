extends Area2D

export var texture = preload("res://assets/bin_returns.png")

export(Global.BinTypeEnum) var type = Global.BinTypeEnum.RETURN

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
