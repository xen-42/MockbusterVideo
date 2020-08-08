extends Area2D
onready var global_vars = get_node("/root/Global")
onready var stream = preload("res://assets/audio/pick_up.wav")

var sound = AudioStreamPlayer2D.new()

var is_dragging = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sound.stream = stream
	self.add_child(sound)
	pass # Replace with function body.

#Functions to be overriden
func _on_stop_drag():
	pass
func _on_start_drag():
	pass

func _process(delta):
	if is_dragging:
		position = get_viewport().get_mouse_position()

func _unhandled_input(event):
	# If no longer holding click, stop dragging
	if event is InputEventMouseButton and not event.pressed and is_dragging:
		is_dragging = false
		Global.draggable_selected = false
		_on_stop_drag()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and not Global.draggable_selected:
		is_dragging = true
		_on_start_drag()
		if not sound.playing:
			sound.play()
		Global.draggable_selected = true # want to avoid dragging many items at once
