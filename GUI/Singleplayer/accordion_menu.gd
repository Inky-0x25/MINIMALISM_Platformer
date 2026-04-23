extends VBoxContainer

func _ready():
	# Connect all section buttons automatically
	for section in get_children():
		var button = section.get_child(0)  # first child = Button
		button.pressed.connect(_on_button_pressed.bind(section))

func _on_button_pressed(active_section):
	# Loop through sections and toggle visibility
	for section in get_children():
		var panel = section.get_node("Level_container")
		panel.visible = (section == active_section) and not panel.visible
