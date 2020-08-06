extends Area2D
onready var global_vars = get_node("/root/Global")

var is_dragging = false

# Called when the node enters the scene tree for the first time.
func _ready():
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
	if event is InputEventMouseButton and not event.pressed:
		is_dragging = false
		Global.draggable_selected = false
		_on_stop_drag()
	# If dragging and mouse is moved, move the item
	#if is_dragging and event is InputEventMouseMotion:
	#	position = event.position

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and not Global.draggable_selected:
		is_dragging = true
		_on_start_drag()
		Global.draggable_selected = true # want to avoid dragging many items at once

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
