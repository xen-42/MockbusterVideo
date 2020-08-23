extends Draggable
class_name Item

signal item_removed(item)

export(Array, Global.ItemTypeEnum) var types = []
onready var tween = $Tween

# Used to signal back to the game that item has been received
signal item_signal(bin_types, item_types)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_stop_drag():
	._on_stop_drag()
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
				if not body.types.has(Global.ItemTypeEnum.SALE):
					SoundEffects.play("bin_drop.wav")
				emit_signal("item_removed", self)
