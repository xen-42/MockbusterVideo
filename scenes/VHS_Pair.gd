extends "res://scripts/Draggable.gd"

const global = preload("res://scripts/Global.gd")
const VHS_scene = preload("res://scenes/VHS.tscn")
const VHS_cover_scene = preload("res://scenes/VHS_Cover.tscn")

var vhs_0 = load("res://assets/vhs_0.png")
var vhs_1 = load("res://assets/vhs_1.png")
var vhs_2 = load("res://assets/vhs_2.png")

export(global.BinTypeEnum) var VHS_type = global.BinTypeEnum.RETURN
export var is_rewound = true
export var due_month = 8
export var due_date = 12

# Need the bin type for checking if VHS is in it
const Bin = preload("res://scenes/Bin.gd")

# Used to signal back to the game that VHS has been received
signal VHS_signal(bin_type, VHS_type, is_rewound)

var child_VHS_cover = null
var has_cover = true

onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	#var child_VHS = VHS_scene.instance()
	var new_sprite = Sprite.new()
	var texture = vhs_0
	if VHS_type == global.BinTypeEnum.REPAIR:
		texture = vhs_1
		#Also have to shift over
		new_sprite.position = Vector2(5,0)
	elif VHS_type == global.BinTypeEnum.TRASH:
		texture = vhs_2
		
	new_sprite.set_texture(texture)
	self.add_child(new_sprite)
	
	child_VHS_cover = VHS_cover_scene.instance()
	if VHS_type == global.BinTypeEnum.PURCHASE:
		child_VHS_cover.purchase = true
	elif VHS_type == global.BinTypeEnum.RENTAL:
		child_VHS_cover.rental = true
	else:
		child_VHS_cover.date_month = due_month
		child_VHS_cover.date_day = due_date
	self.add_child(child_VHS_cover)
	
	connect("input_event", self, "_on_VHS_Pair_input_event")
	connect("VHS_signal", get_node("/root/Level"), "_on_Level_VHS_signal")

func _on_VHS_Pair_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.doubleclick:
		print("Double clicked")
		if child_VHS_cover != null:
			child_VHS_cover.remove_cover()
			has_cover = false

func _on_stop_drag():
	var bodies = self.get_overlapping_areas()
	if bodies.size() > 0:
		for body in bodies:
			if body is Bin:
				print("VHS put in bin %s" % body.type)
				emit_signal("VHS_signal", body.type, VHS_type, is_rewound)

				tween.interpolate_property(self, "modulate",
					Color(1,1,1,1), Color(1,1,1,0), 0.4,
					Tween.TRANS_EXPO, Tween.EASE_OUT)
				tween.interpolate_callback(self, 0.5, "queue_free")
				tween.start()
				
				self.input_pickable = false
				
				get_parent().child_items.erase(self)
