extends Control

var waiting_for_input = false
var action_to_rebind = ""

func _ready():
	var back_button = find_child("Back")
	GlobalNav.link_button_to_scene(back_button, "res://GUI/Settings/Settings.tscn")
	
	# current binded keyname display
	var container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
	for player_container in container.get_children():
		for key_container in player_container.get_children():
			for child in key_container.get_children():
				if "Button" in child.name:
					var action = child.get_meta("action")
					child.text = get_action_key_text(action)
					print(action + " " + child.text)
					child.pressed.connect(start_rebinding.bind(child, action))

func start_rebinding(button, action_name):
	button.text = "@control_press_key@"
	waiting_for_input = true
	action_to_rebind = action_name
	
func _input(event):
	if waiting_for_input and event is InputEventKey and event.pressed:
		rebind_action(action_to_rebind, event)
		waiting_for_input = false

func rebind_action(action_name, event):
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	self.find_child(action_name + "Button").text = get_action_key_text(action_name)

func get_action_key_text(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	
	if events.size() > 0:
		return events[0].as_text()
	
	return "Unassigned"
