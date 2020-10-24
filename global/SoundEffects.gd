extends Node2D

var sound_path = "res://assets/audio"
var music_path = "res://assets/audio/music"
var phoneme_path = "res://assets/audio/phonemes"
var sounds = {}
var playback_position = {}
var tweens = {}

var sound_file_names = [
	"bin_drop.wav",
	"click.wav",
	"money.wav",
	"paper_rip.wav",
	"pick_up.wav",
	"place_sticker.wav",
	"receipt.wav",
	"remove_cover.wav",
	"rewind.wav",
	"take_sticker.wav",
	"ticking.wav",
	"vcr_eject.wav",
	"vcr_insert.wav",
	"walk.wav",
]

var song_names = [
	"song.ogg",
	"game_theme.ogg",
	"night.ogg",
	"night2.ogg"
]

var phoneme_names = [
	"a.wav",
	"b.wav",
	"c.wav",
	"d.wav",
	"e.wav",
	"f.wav",
	"g.wav",
	"h.wav",
	"i.wav",
	"j.wav",
	"k.wav",
	"l.wav",
	"m.wav",
	"n.wav",
	"o.wav",
	"p.wav",
	"q.wav",
	"r.wav",
	"s.wav",
	"t.wav",
	"u.wav",
	"v.wav",
	"w.wav",
	"x.wav",
	"y.wav",
	"z.wav",
]

func _ready():
	# Load all sounds
	for f in sound_file_names:
		print("Found %s" % f)
		add_new_stream_player(sound_path, f, "Sounds")

	# Load all music
	for f in song_names:
		print("Found %s" % f)
		add_new_stream_player(music_path, f, "Music")
		add_music_stream_tween(f)

	# Load all phonemes
	for f in phoneme_names:
		add_new_stream_player(phoneme_path, f, "Sounds")

func add_new_stream_player(directory, file_name, bus):
	var stream_player = AudioStreamPlayer.new()
	stream_player.bus = bus
	stream_player.set_stream(load(directory + "/" + file_name))
	add_child(stream_player)
	sounds[file_name] = stream_player

func add_music_stream_tween(file_name):
	var tween = Tween.new()
	add_child(tween)
	tweens[file_name] = tween

func play(file, pitch=1):
	if sounds.has(file):
		sounds[file].set_pitch_scale(pitch)
		sounds[file].play()
		if playback_position.has(file):
			sounds[file].seek(playback_position[file])
		sounds[file].volume_db = 0
	else:
		print("%s not found" % file)

func stop(file, keep_playback_position = false):
	if sounds.has(file):
		if tweens.has(file):
			tweens[file].stop(sounds[file])
			tweens[file].stop(self)
		if keep_playback_position:
			playback_position[file] = sounds[file].get_playback_position()
		elif playback_position.has(file):
			playback_position[file] = 0
		sounds[file].stop()
		sounds[file].volume_db = 0
	else:
		print("%s not found" % file)

func fade_in(file_name, time):
	if tweens.has(file_name) and sounds.has(file_name):
		var sound = sounds[file_name]
		var tween = tweens[file_name]
		tween.stop(self)
		tween.stop(sound)
		tween.interpolate_property(
			sound, "volume_db", -80, 0, time, Tween.TRANS_SINE, Tween.EASE_IN, 0
		)
		tween.start()
		play(file_name)
		sounds[file_name].volume_db = -80
	else:
		print("Couldn't find %s" % file_name)

func fade_out(file_name, time, keep_playback_position = false):
	if tweens.has(file_name) and sounds.has(file_name):
		var sound = sounds[file_name]
		var tween = tweens[file_name]
		tween.stop(self)
		tween.stop(sound)
		tween.interpolate_property(
			sound, "volume_db", 0, -80, time, Tween.TRANS_SINE, Tween.EASE_IN, 0
		)
		tween.interpolate_callback(self, time, "stop", file_name, keep_playback_position)
		tween.start()
	else:
		print("Couldn't find %s" % file_name)

func is_playing(file):
	if sounds.has(file):
		return sounds[file].playing
	else:
		print("%s not found" % file)
