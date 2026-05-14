extends Control

@onready var menu_container = $MarginContainer/ScrollContainer/VBoxContainer/Accordion_menuContainer

func _ready():
	# Connect all section buttons automatically
	var locked = false
	for section in menu_container.get_children():
		if locked:
			section.visible = false
		if section.name.contains(GlobalVar.unlocked_stage_name):
			locked = true
		for child in section.get_children():
			if "Button" in child.name:
				child.pressed.connect(_on_button_pressed.bind(section))
			if "LevelContainer" in child.name:
				for level in child.get_children():
					var level_name = level.name.split("_")
					var level_path = "res://Levels/" + level_name[0] + "/"+ level_name[1] +".tscn"
					GlobalNav.link_button_to_scene(level, level_path)
	
	var back_button = find_child("Back")
	
	if GlobalVar.local_multiplayer_enabled or GlobalVar.remote_multiplayer_enabled:
		GlobalNav.link_button_to_scene(back_button, "res://GUI/Multiplayer/Multiplayer.tscn")
	else:
		GlobalNav.link_button_to_scene(back_button, "res://GUI/Main/Main.tscn")

func _on_button_pressed(active_section):
	# Loop through sections and toggle visibility
	for section in menu_container.get_children():
		var panel = section.get_node("LevelContainer")
		panel.visible = (section == active_section) and not panel.visible
