extends Area2D

enum MONTH {Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec}
var month_length = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

export var purchase = false
export var rental = false
export var date_month = 1
export var date_day = 1

onready var month_label = $Node2D/Month
onready var date_label = $Node2D/Date
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	if purchase:
		date_label.text = "SA"
		month_label.text = "LE"
	elif rental:
		date_label.text = "RE"
		month_label.text = "NT"
	else:
		month_label.text = "%02d" % date_month
		date_label.text = "%02d" % date_day

func remove_cover():
	# Have the cover move up and disappear
	var end_position = Vector2(self.position.x, self.position.y - 40)
	tween.interpolate_property(self, "position",
		self.position, end_position, 1.2,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 1,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_callback(self, 1.2, "queue_free")
	tween.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
