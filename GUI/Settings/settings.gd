extends Node

func _ready():
	# back button signal connect
	var back_button = find_child("Back")
	GlobalNav.link_button_to_scene(back_button, "res://GUI/Main/Main.tscn")
	
	# language option button selection handling
	var language_button = find_child("LanguageButton")
	language_button.item_selected.connect(_on_language_selected)
	
	var language = GlobalVar.current_language
	var language_index = Language.supported_languages.find(language)
	
	if language_index != -1:
		language_button.select(language_index)
	
	# fps cap option button selection handling
	var frame_lock_button = find_child("FrameLockButton")
	frame_lock_button.item_selected.connect(_on_frame_rate_selected)
	
	var frame_rate = GlobalVar.fps_cap;
	var frame_rate_index = GlobalVar.supported_fps_caps.find(frame_rate)
	
	if frame_rate_index != -1:
		frame_lock_button.select(frame_rate_index)
	
	# music volume slider handling
	var music_volume_slider = find_child("MusicVolumeButton")
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	
	music_volume_slider.set_value(GlobalVar.music_volume)
	
	# sound volume slider handling
	var sound_volume_slider = find_child("SoundVolumeButton")
	sound_volume_slider.value_changed.connect(_on_sound_volume_changed)
	
	sound_volume_slider.set_value(GlobalVar.sound_volume)
	
	# controls edit button handling
	var controls_button = find_child("ControlsButton")
	GlobalNav.link_button_to_scene(controls_button, "res://GUI/Settings/Controls/Controls.tscn")

func _on_language_selected(index):
	Language.set_language(Language.supported_languages[index])

func _on_frame_rate_selected(index):
	GlobalVar.fps_cap = GlobalVar.supported_fps_caps[index]
	Engine.max_fps = GlobalVar.fps_cap

func _on_music_volume_changed(value):
	GlobalVar.music_volume = value
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func _on_sound_volume_changed(value):
	GlobalVar.sound_volume = value
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), db)
