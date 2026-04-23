extends VBoxContainer

func _ready():
# Connect all buttons automatically to the corresponding scene
	for button in get_children():
		if button is Button:
			var scene_path = "res://GUI/%s/%s.tscn" % [button.name, button.name]
			GlobalNav.link_button_to_scene(button, scene_path)
	GlobalNav.scene_to_return = "res://GUI/Main/Main.tscn"
