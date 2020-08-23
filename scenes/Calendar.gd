extends Node2D

onready var month_label = $CalendarPage/MonthLabel
onready var day_label = $CalendarPage/DayLabel
onready var calendar_page = $CalendarPage
onready var tween = $Tween

var delta_y = 30
var delta_x = 30
var delta_r = deg2rad(-60)
var delta_t = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_date(day, month):
	month_label.text = "%02d" % month
	day_label.text = "%02d" % day

func change_date(day, month):
	var new_page = calendar_page.duplicate()
	self.add_child(new_page)
	set_date(day, month)
	
	# Make sure the new page goes over other objects
	new_page.z_index = 5
	
	var end_position = new_page.position
	end_position.y += delta_y
	end_position.x += delta_x
	tween.interpolate_property(new_page, "position",
		new_page.position, end_position, delta_t,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(new_page, "rotation",
		new_page.rotation, new_page.rotation + delta_r, delta_t,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(new_page, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), delta_t,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_callback(new_page, delta_t, "queue_free")
	tween.start()
	
	SoundEffects.play("paper_rip.wav")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
