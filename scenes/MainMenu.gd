extends Node2D

var song = "song.ogg"
var timer = 0

func _ready():
	SoundEffects.play(song)

func _process(delta):
	timer += delta
	
	$CanvasLayer/mockbuster_logo.rotation = PI / 24.0 * sin(PI * timer)
	var scale = 0.05 * cos(PI * timer) + 1
	$CanvasLayer/mockbuster_logo.scale = Vector2(scale, scale)
	
	var rotation = PI / 24.0 * sin(PI * timer)
	$CanvasLayer/vhs_0.rotation = rotation
	$CanvasLayer/vhs_1.rotation = -rotation

func _on_QuitButton_button_down():
	get_tree().quit()

func _on_EndlessButton_button_down():
	Global.endless_mode = true
	get_tree().change_scene("res://scenes/levels/Game.tscn")

func _on_PlayButton_button_down():
	Global.endless_mode = false
	get_tree().change_scene("res://scenes/levels/Game.tscn")

func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
			get_tree().paused = false
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			get_tree().paused = true

func _exit_tree():
	SoundEffects.stop(song)
