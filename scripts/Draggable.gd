extends Area2D
class_name Draggable

onready var collision_shape = $CollisionShape2D

onready var shader = preload("res://shader/DropShadow.shader")

var is_dragging = false

var max_x = 900
var min_x = 0
var max_y = 600
var min_y = 0

onready var default_material = self.material
var dropshadow_material = ShaderMaterial.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if collision_shape != null:
		var shape = collision_shape.shape
		
		if shape is RectangleShape2D:
			max_x -= shape.extents.x * self.scale.x
			min_x += shape.extents.x * self.scale.x
			max_y -= shape.extents.y * self.scale.y
			min_y += shape.extents.y * self.scale.y
		elif shape is CircleShape2D:
			max_x -= shape.radius * self.scale.x
			min_x += shape.radius * self.scale.x
			max_y -= shape.radius * self.scale.y
			min_y += shape.radius * self.scale.y
	
	dropshadow_material.shader = shader


#Functions to be overriden
func _on_stop_drag():
	self.z_index -= 1
	self.material = default_material
	
func _on_start_drag():
	self.z_index += 1
	self.material = dropshadow_material

func _process(delta):
	if is_dragging:
		# We want to stop it from going off screen though
		var mouse_position = get_viewport().get_mouse_position()
		var x = clamp(mouse_position.x, min_x, max_x) / 3
		var y = clamp(mouse_position.y, min_y, max_y) / 3
		
		position = Vector2(x, y)

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
		if not SoundEffects.is_playing("pick_up.wav"):
			SoundEffects.play("pick_up.wav")
		Global.draggable_selected = true # want to avoid dragging many items at once
