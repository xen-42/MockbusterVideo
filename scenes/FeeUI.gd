extends Node

export(Global.ItemTypeEnum) var fee_type = Global.ItemTypeEnum.LATE
var price = 2

onready var label = $Label
onready var count_label = $CountLabel
onready var plus_button = $PlusButton
onready var minus_button = $MinusButton

var count = 0

signal total_change(change)

# Called when the node enters the scene tree for the first time.
func _ready():
	var type_string = str(Global.ItemTypeEnum.keys()[fee_type]).to_lower()
	type_string[0] = type_string[0].to_upper()
	
	price = Global.prices[fee_type]
	label.text = "%s\n($%.2f)" % [type_string, self.price]
	reset()
	connect("total_change", get_node("/root/Level/GameScene/UI"), "_on_UI_total_change")

func increase_count():
	if count < 10:
		count = count + 1
		count_label.text = "%d" % count
		emit_signal("total_change", price)

func decrease_count():
	if count > 0:
		count = count - 1
		count_label.text = "%d" % count
		emit_signal("total_change", -price)

func reset():
	count = 0
	count_label.text = "%d" % count

func _on_PlusButton_button_down():
	SoundEffects.play("click.wav")
	increase_count()

func _on_MinusButton_button_down():
	SoundEffects.play("click.wav")
	decrease_count()

