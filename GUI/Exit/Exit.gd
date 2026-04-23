extends Node

func _ready():
	GlobalVar.save_settings()
	GlobalVar.save_statistics()
	GlobalVar.save_data()
	find_child("Confirm").pressed.connect(get_tree().quit)
	GlobalNav.link_button_to_scene(find_child("Cancel"), GlobalNav.scene_to_return)
