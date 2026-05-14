extends Control

func _ready():
	var back_button = find_child("Back")
	GlobalNav.link_button_to_scene(back_button, "res://GUI/Main/Main.tscn")
