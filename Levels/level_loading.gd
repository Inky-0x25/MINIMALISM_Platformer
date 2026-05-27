extends Node

@onready var spawn_point_1 = find_child("PlayerSpawner1")
@onready var spawn_point_2 = find_child("PlayerSpawner2")

func _ready() -> void:
	PlayersManager.spawn_players(spawn_point_1.position, spawn_point_2.position)
