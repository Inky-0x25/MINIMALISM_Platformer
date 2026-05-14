extends CanvasLayer

@onready var confirm_button = $HBoxContainer/Confirm
@onready var cancel_button = $HBoxContainer/Cancel

func _ready():
	confirm_button.pressed.connect(_on_confirm)
	cancel_button.pressed.connect(_turn_off)

func _on_confirm():
	get_tree().quit()

func _turn_off():
	self.hide()
