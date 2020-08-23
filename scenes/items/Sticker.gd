extends Draggable
class_name Sticker

onready var day_label = $DayLabel
onready var month_label = $MonthLabel
onready var tween = $Tween

var day = 1
var month = 1

signal sticker_taken()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_date(d, m):
	day_label.text = "%02d" % d
	month_label.text = "%02d" % m
	
	day = d
	month = m

func _on_start_drag():
	._on_start_drag()
	emit_signal("sticker_taken")

func _on_stop_drag():
	#Check if overlapping with VHS 
	._on_stop_drag()
	var bodies = self.get_overlapping_areas()
	var on_vhs_cover = false
	
	if bodies.size() > 0:
		for body in bodies:
			if body is VHS:
				if body.types.has(Global.ItemTypeEnum.RENTAL):
					# Make the sticker parented onto the rental and make it no movable
					print("Placed on VHS")
					
					body.types.append(Global.ItemTypeEnum.STICKERED)
					body.day_label.text = "%02d" % day
					body.month_label.text = "%02d" % month
					
					self.queue_free()
					# return to stop it processing other colliding bodies.
					# this allowed for one sticker to go on multiple VHS
					return
	# If not on vhs have sticker fade out
	if not on_vhs_cover:
		self.input_pickable = false
		tween.interpolate_property(self, "modulate",
			Color(1,1,1,1), Color(1,1,1,0), 0.4,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.interpolate_callback(self, 1, "queue_free")
		tween.start()
