extends TextureButton

export var text = "BUTTON"
onready var label = $Label

var is_hovered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = text

func _on_MenuButton_button_down():
	SoundEffects.play("click.wav")


func _on_QuitButton_button_down():
	pass # Replace with function body.


func _on_MenuButton_mouse_entered():
	if not is_hovered:
		is_hovered = true
		self.modulate = Color(0.9, 0.9, 0.9)


func _on_MenuButton_mouse_exited():
	if is_hovered:
		is_hovered = false
		self.modulate = Color(1,1,1)
