extends Control

@onready var SceneButtonContainer = $VBoxContainer/SceneButtonContainer
@onready var ExitButton = $VBoxContainer/ExitButton

func _ready():
	# Connect all buttons automatically to the corresponding scene
	for button in SceneButtonContainer.get_children():
		if button is Button:
			var scene_path = "res://GUI/%s/%s.tscn" % [button.name, button.name]
			GlobalNav.link_button_to_scene(button, scene_path)
	
	ExitButton.pressed.connect(GlobalNav.trigger_exit_ui)
