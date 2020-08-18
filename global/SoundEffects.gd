extends Node2D

var sound_path = "res://assets/audio"
var music_path = "res://assets/audio/music"
var sounds = {}
var music = {}

func _ready():
	# Load all sounds
	var sound_files = Global.list_files_in_directory(sound_path)
	for f in sound_files:
		add_new_stream_player(sound_path, f, sounds, "Sounds")
	
	# Load all music
	var music_files = Global.list_files_in_directory(music_path)
	for f in music_files:
		add_new_stream_player(music_path, f, music, "Music")

func add_new_stream_player(directory, file, dictionary, bus):
	var stream_player = AudioStreamPlayer.new()
	stream_player.bus = bus
	stream_player.stream = load(directory + "/" + file)
	add_child(stream_player)
	
	dictionary[file] = stream_player

func play(file):
	if sounds.has(file):
		sounds[file].play()
	elif music.has(file):
		music[file].play()
	else:
		print("%s not found" % file)

func stop(file):
	if sounds.has(file):
		sounds[file].stop()
	elif music.has(file):
		music[file].stop()
	else:
		print("%s not found" % file)

func is_playing(file):
	if sounds.has(file):
		return sounds[file].playing
	elif music.has(file):
		return music[file].playing
	else:
		print("%s not found" % file)
