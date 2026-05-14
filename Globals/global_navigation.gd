extends Node

# Handle global shortcut
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		trigger_exit_ui()

# Active the exit ui
func trigger_exit_ui():
	GlobalVar.save_everything()
	ExitMenu.show()

# Change to the scene with the corresponding name
func change_scene(scene_path: String):
	get_tree().change_scene_to_file(scene_path)

# Link a button to a scene
func link_button_to_scene(button: Button, scene_path: String):
	button.pressed.connect(GlobalNav.change_scene.bind(scene_path))
