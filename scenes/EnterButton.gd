extends TextureButton

var text_disabled = false
var is_hovered = false

onready var text_label = $Label

func _ready():
	pass # Replace with function body.

func _process(delta):
	if self.disabled and not text_disabled:
		text_disabled = true
		text_label.add_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
		if is_hovered:
			is_hovered = false
			self.modulate = Color(1,1,1)
	
	if not self.disabled and text_disabled:
		text_disabled = false
		text_label.add_color_override("font_color", Color(0, 0, 0, 1))


func _on_EnterButton_mouse_entered():
	if not disabled and not is_hovered:
		is_hovered = true
		self.modulate = Color(0.9, 0.9, 0.9)


func _on_EnterButton_mouse_exited():
	if is_hovered:
		is_hovered = false
		self.modulate = Color(1,1,1)
