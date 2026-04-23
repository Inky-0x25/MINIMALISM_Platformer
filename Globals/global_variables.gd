extends Node

# file paths
var setting_file = "user://settings.cfg"
var statistic_file = "user://statistics.cfg"
var data_file = "user://data.cfg"

# global variables
const supported_fps_caps = [30, 60, 90, 120, 0]
var last_scene_path : String = ""

	# setting variables
var current_language : String = "en"
var fps_cap : int = 60
var music_volume : int = 100
var sound_volume : int = 100

	# statistics variables
var total_play_time : float = 0

	# data variables
var current_play_time : float = 0
var current_map : String = ""

func _ready():
	load_settings()
	load_statistics()
	load_data()

func _process(delta):
	current_play_time += delta

# loading and saving functions
func load_settings():
	var config = ConfigFile.new()
	var err = config.load(setting_file)
	
	if err == OK:
		# load language
		current_language = config.get_value("settings", "language", "")
		if current_language in Language.supported_languages:
			Language.set_language(current_language)
		else:
			var system_lang = OS.get_locale().split("_")[0]
			Language.set_language(system_lang)
		
		# load fps cap
		fps_cap = config.get_value("settings", "fps_cap", 0)
		Engine.max_fps = fps_cap
		
		# load music volume
		music_volume = config.get_value("settings", "music_volume", 100)
		var mdb = linear_to_db(music_volume)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), mdb)
		
		# load sound volume
		sound_volume = config.get_value("settings", "sound_volume", 100)
		var sdb = linear_to_db(sound_volume)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), sdb)
		
		# load keybidings
		for action in config.get_section_keys("input"):
			var key_string = config.get_value("input", action)
			
			var event = InputEventKey.new()
			event.keycode = OS.find_keycode_from_string(key_string)
			
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
	else:
		var system_lang = OS.get_locale().split("_")[0]
		Language.set_language(system_lang)

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("settings", "language", current_language)
	config.set_value("settings", "fps_cap", fps_cap)
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "sound_volume", sound_volume)
	
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			config.set_value("input", action, events[0].as_text())
	
	config.save(setting_file)

func load_statistics():
	var config = ConfigFile.new()
	var err = config.load(statistic_file)
	
	if err == OK:
		total_play_time = config.get_value("statistics", "total_play_time", 0)
		

func save_statistics():
	var config = ConfigFile.new()
	
	config.set_value("statistics", "total_play_time", total_play_time+current_play_time)
	
	config.save(statistic_file)

func load_data():
	
	var config = ConfigFile.new()
	var err = config.load(data_file)
	
	if err == OK:
		current_map = config.get_value("save", "map", "")
	else:
		print("No save file found, starting fresh")

func save_data():
	var config = ConfigFile.new()
	config.set_value("save", "map", current_map)
	
	config.save(data_file)
