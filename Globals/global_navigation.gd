extends Node

var scene_to_return = ""

# Handle global shortcut
func _input(event):
	if event.is_action_pressed("ui_cancel") and get_tree().current_scene.scene_file_path != "res://GUI/Exit/Exit.tscn":
		scene_to_return = get_tree().current_scene.scene_file_path
		change_scene("res://GUI/Exit/Exit.tscn")

# Change to the scene with the corresponding name
func change_scene(scene_path: String):
	get_tree().change_scene_to_file(scene_path)

# Link a button to a scene
func link_button_to_scene(button: Button, scene_path: String):
	button.pressed.connect(GlobalNav.change_scene.bind(scene_path))
