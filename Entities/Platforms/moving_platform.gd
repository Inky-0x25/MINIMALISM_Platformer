extends AnimatableBody2D

@export var point_a = Vector2(0,0)
@export var point_b = Vector2(300,0)

@export var speed = 100.0

var target


func _ready():
	global_position = point_a
	target = point_b

func _physics_process(delta):
	global_position = global_position.move_toward(target, speed*delta)
	
	if global_position.distance_to(target) < 1:
		if target == point_a:
			target = point_b
		else:
			target = point_a
