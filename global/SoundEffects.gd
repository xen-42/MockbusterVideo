extends Node2D

var sound_path = "res://assets/audio"
var music_path = "res://assets/audio/music"
var phoneme_path = "res://assets/audio/phonemes"
var sounds = {}

func _ready():
	# Load all sounds
	var sound_files = Global.list_files_in_directory(sound_path)
	for f in sound_files:
		add_new_stream_player(sound_path, f, "Sounds")
	
	# Load all music
	var music_files = Global.list_files_in_directory(music_path)
	for f in music_files:
		add_new_stream_player(music_path, f, "Music")
	
	# Load all phonemes
	var phoneme_files = Global.list_files_in_directory(phoneme_path)
	for f in phoneme_files:
		add_new_stream_player(phoneme_path, f, "Sounds")

func add_new_stream_player(directory, file, bus):
	var stream_player = AudioStreamPlayer.new()
	stream_player.bus = bus
	stream_player.stream = load(directory + "/" + file)
	add_child(stream_player)
	
	sounds[file] = stream_player

func play(file, pitch=1):
	if sounds.has(file):
		sounds[file].set_pitch_scale(pitch)
		sounds[file].play()
	else:
		print("%s not found" % file)

func stop(file):
	if sounds.has(file):
		sounds[file].stop()
	else:
		print("%s not found" % file)

func is_playing(file):
	if sounds.has(file):
		return sounds[file].playing
	else:
		print("%s not found" % file)
