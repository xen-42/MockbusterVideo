extends Node2D

onready var continue_button = $ContinueButton
onready var end_game_node = $EndGameNode2D
onready var end_game_node_label = $EndGameNode2D/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			unpause()
		else:
			pause()

func pause():
	get_tree().paused = true
	visible = true

func unpause():
	get_tree().paused = false
	visible = false

func end_game(win):
	pause()
	continue_button.visible = false
	end_game_node.visible = true
	if win:
		end_game_node_label.text = "YOU WIN!\nWith the money and loyalty you have earned, Mockbuster video will surely never go bankrupt ever I swear."
	else:
		end_game_node_label.text = "YOU LOSE!\nBankruptcy!\nMockbuster Video is no more..."

func _on_ContinueButton_button_down():
	unpause()

func _on_MainMenuButton_button_down():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/MainMenu.tscn")
