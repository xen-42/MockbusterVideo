extends Item
class_name VHS

var has_cover = true
var is_rewound = true

onready var cover_sprite = $Cover_Sprite
onready var day_label = $Cover_Sprite/DayLabel
onready var month_label = $Cover_Sprite/MonthLabel
onready var vhs_sprite = $VHS_Sprite

var due_day = 1
var due_month = 1

# Preload possible VHS
var vhs_0 = load("res://assets/VHS/vhs_0.png")
var vhs_1 = load("res://assets/VHS/vhs_1.png")
var vhs_2 = load("res://assets/VHS/vhs_2.png")
var vhs_cover = load("res://assets/VHS/cover_0.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	# For double clicking
	connect("input_event", self, "_on_VHS_input_event")
	
	# Used for putting into VCR
	is_rewound = !types.has(Global.ItemTypeEnum.REWIND)
	
	# Write onto cover
	if types.has(Global.ItemTypeEnum.PURCHASE):
		day_label.text = "SA"
		month_label.text = "LE"
	elif types.has(Global.ItemTypeEnum.RENTAL):
		day_label.text = "RE"
		month_label.text = "NT"
	else:
		if types.has(Global.ItemTypeEnum.TRASH):
			vhs_sprite.texture = vhs_2
		elif types.has(Global.ItemTypeEnum.REPAIR):
			vhs_sprite.texture = vhs_1
		day_label.text = "%02d" % due_day
		month_label.text = "%02d" % due_month

func _on_VHS_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.doubleclick:
		print("Double clicked")
		if has_cover:
			# Have the cover move up and disappear
			var end_position = Vector2(cover_sprite.position.x, cover_sprite.position.y - 40)
			tween.interpolate_property(cover_sprite, "position",
				cover_sprite.position, end_position, 0.8,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.interpolate_property(cover_sprite, "modulate",
				Color(1,1,1,1), Color(1,1,1,0), 0.4,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.interpolate_callback(cover_sprite, 1.2, "queue_free")
			tween.start()
			
			SoundEffects.play("remove_cover.wav")
			
			has_cover = false

func _on_stop_drag():
	._on_stop_drag()
	var bodies = self.get_overlapping_areas()
	if bodies.size() > 0:
		for body in bodies:
			if body is VCR:
				print("Put VHS in VCR")
				if not has_cover and types.has(Global.ItemTypeEnum.RETURN):
					body.insert_vhs(self)
