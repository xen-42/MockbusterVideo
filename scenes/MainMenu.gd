extends Node2D

var timer = 0

func _ready():
	pass 

func _process(delta):
	timer += delta
	
	$CanvasLayer/mockbuster_logo.rotation = PI / 24.0 * sin(PI * timer)
	var scale = 0.2 * cos(PI * timer) + 4
	$CanvasLayer/mockbuster_logo.scale = Vector2(scale, scale)
	
	var rotation = PI / 24.0 * sin(PI * timer)
	$CanvasLayer/vhs_0.rotation = rotation
	$CanvasLayer/vhs_1.rotation = -rotation

func _on_QuitButton_button_down():
	get_tree().quit()

func _on_HowToButton_button_down():
	get_tree().change_scene("res://scenes/HowToScene.tscn")

func _on_PlayButton_button_down():
	get_tree().change_scene("res://scenes/Level.tscn")

func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
			get_tree().paused = false
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			get_tree().paused = true
