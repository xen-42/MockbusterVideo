extends Area2D
class_name VCR

onready var rewind_sprite = $TV/RewindSprite
onready var temp_vhs = $VCRNode/VHS
var stored_vhs = null
onready var tween = $VCRNode/Tween
onready var cover = $VCRNode/Cover

var vhs_start_position = Vector2(1,25)
var vhs_stored_position = Vector2(1,6)

var cover_start_position = Vector2(0.5, 11.5)
var cover_stop_position = Vector2(0.5, 9)

var insert_time = 0.8
var eject_time = 0.2
var rewind_time = 1.2

# Called when the node enters the scene tree for the first time.
func _ready():
	rewind_sprite.speed_scale = 2
	rewind_sprite.visible = false
	
	temp_vhs.visible = false

func rewind():
	SoundEffects.play("rewind.wav")
	rewind_sprite.visible = true
	rewind_sprite.play()

func stop_rewind():
	SoundEffects.stop("rewind.wav")
	rewind_sprite.visible = false
	rewind_sprite.stop()

func insert_vhs(vhs):
	SoundEffects.play("vcr_insert.wav")
	stored_vhs = vhs
	stored_vhs.visible = false
	stored_vhs.input_pickable = false
	
	temp_vhs.visible = true
	temp_vhs.texture = stored_vhs.vhs_sprite.texture
	
	# Move up cover, move in VHS, move down cover
	tween.interpolate_property(temp_vhs, "position",
		vhs_start_position, vhs_stored_position, insert_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(cover, "scale",
		cover.scale, Vector2(1,0), insert_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(cover, "position",
		cover.position, cover_stop_position, insert_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_callback(self, insert_time, "close_cover")
	tween.interpolate_callback(self, insert_time, "process_vhs")
	tween.start()

func close_cover():
	tween.interpolate_property(cover, "scale",
		cover.scale, Vector2(1,1), insert_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(cover, "position",
		cover.position, cover_start_position, insert_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()

func eject_vhs():
	SoundEffects.play("vcr_eject.wav")
	# Move up cover, move out VHS, move down cover
	tween.interpolate_property(temp_vhs, "position",
		vhs_stored_position, vhs_start_position, eject_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(cover, "scale",
		cover.scale, Vector2(1,0), eject_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(cover, "position",
		cover.position, cover_stop_position, eject_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_callback(self, eject_time, "close_cover")
	tween.interpolate_callback(self, eject_time, "free_stored_vhs")
	tween.start()

func free_stored_vhs():
	stored_vhs.visible = true
	stored_vhs.input_pickable = true
	stored_vhs.rotation = deg2rad(-90)
	stored_vhs.position = self.position + vhs_start_position * self.scale.y
	
	temp_vhs.visible = false

func process_vhs():
	if stored_vhs.is_rewound:
		eject_vhs()
	else:
		stored_vhs.is_rewound = true
		rewind()
		tween.interpolate_callback(self, rewind_time, "stop_rewind")
		tween.interpolate_callback(self, rewind_time, "eject_vhs")
		tween.start()
