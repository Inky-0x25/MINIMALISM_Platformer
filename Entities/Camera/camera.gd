extends Camera2D

@export var follow_speed: float = 24.0

@export var min_zoom: float = 0.5
@export var max_zoom: float = 1.0
@export var max_player_distance: float = 1200.0

@export var zoom_speed: float = 4.0

func _ready() -> void:
	self.enabled = GlobalVar.local_multiplayer_enabled

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("local_players")
	
	if not players.is_empty():
		### Calculate center position
		var center := Vector2.ZERO
		for player in players:
			center += player.global_position
		center /= players.size()
		
		### Smooth follow
		global_position = global_position.lerp(center,follow_speed * delta)
		
		### Calculate furthest player distance
		var max_distance := 0.0
		
		for i in range(players.size()):
			for j in range(i + 1, players.size()):
				var distance = players[i].global_position.distance_to(players[j].global_position)
				if distance > max_distance:
					max_distance = distance
		
		### Determine zoom
		var zoom_factor = lerp(max_zoom, min_zoom, clamp(max_distance / max_player_distance, 0.0, 1.0))
		
		### Smooth zoom
		var target_zoom = Vector2(zoom_factor, zoom_factor)
		
		zoom = zoom.lerp(target_zoom, zoom_speed * delta)
