extends Node2D

var day = 1
var month = 1

onready var sticker = $Sticker
onready var sticker_type = preload("res://scenes/items/Sticker.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	sticker.connect("sticker_taken", self, "_on_StickerStack_sticker_taken")

func _on_StickerStack_sticker_taken():
	# Make a new sticker to replace it
	var new_sticker = sticker.duplicate()
	new_sticker.connect("sticker_taken", self, "_on_StickerStack_sticker_taken")
	new_sticker.day = day
	new_sticker.month = month
	
	#Switch the sticker to be a child of the parent instead
	self.remove_child(sticker)
	self.get_parent().add_child(sticker)
	
	#Increase z index so it goes over VHS tapes
	sticker.z_index = 6
	
	# Add the new sticker to the stack
	self.add_child(new_sticker)
	sticker = new_sticker
	# Gotta set it to 0 bc the draggable code increased it when it was grabbed.
	sticker.z_index = 0

func set_date(d, m):
	day = d
	month = m
	
	sticker.set_date(day, month)

