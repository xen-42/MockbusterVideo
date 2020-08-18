extends Draggable
class_name Item

export(Array, Global.ItemTypeEnum) var types = []
onready var tween = $Tween

# Used to signal back to the game that item has been received
signal item_signal(bin_types, item_types)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("item_signal", get_node("/root/Level"), "_on_Level_item_signal")

func _on_stop_drag():
	var bodies = self.get_overlapping_areas()
	if bodies.size() > 0:
		for body in bodies:
			if body is Bin:
				emit_signal("item_signal", body.types, types)

				tween.interpolate_property(self, "modulate",
					Color(1,1,1,1), Color(1,1,1,0), 0.4,
					Tween.TRANS_EXPO, Tween.EASE_OUT)
				tween.interpolate_callback(self, 1, "queue_free") 
				tween.start()
				
				self.input_pickable = false
				if not body.types.has(Global.ItemTypeEnum.PURCHASE):
					SoundEffects.play("bin_drop.wav")
				if "child_items" in get_parent():
					get_parent().child_items.erase(self)
