extends Node

@export var player_scene: PackedScene = preload("res://Entities/Player/Player.tscn")

var players = {"1_1":{"peer_id" : 1, "slot" : 1, "name" : ""}}
var local_player_count = 1
var max_player_on_a_machine = 2


signal _players_data_update()



### MODIFY PLAYER LIST
# Add player to the player list 
func add_player(peer_id, slot, player_name):
	var id = "%s_%s" % [peer_id, slot]
	if not players.has(id):
		players[id] = {
			"peer_id": peer_id,
			"slot": slot,
			"name": player_name
		}
		_players_data_update.emit()

# Add player to the list for everyone
func add_player_for_all(peer_id, slot, player_name):
	add_player(peer_id, slot, player_name)
	if GlobalVar.remote_multiplayer_enabled:
		Networking.send_to_others(
				{"type": "add_player", 
				"peer_id": peer_id, 
				"slot": slot,
				"name": player_name})

# Remove player from the player list
func remove_player(peer_id, slot):
	var id = "%s_%s" % [peer_id, slot]
	if players.has(id):
		players.erase(id)
		_players_data_update.emit()

# Remove player from the list for everyone
func remove_player_for_all(peer_id, slot):
	remove_player(peer_id, slot)
	if GlobalVar.remote_multiplayer_enabled:
		Networking.send_to_others(
				{"type": "remove_player", 
				"peer_id": peer_id, 
				"slot": slot})

# Remove a peer's all players
func remove_peer(peer_id):
	for i in range(max_player_on_a_machine):
		remove_player(peer_id, i+1)

# Remove all remote players from list
func remove_all_remote_players():
	var local_id = str(Networking.get_local_id())
	for id in players:
		var splitted_id = id.split("_")
		if local_id != splitted_id[0]:
			remove_player(splitted_id[0], splitted_id[1])
	_players_data_update.emit()

# Change name to existing player
func change_name(peer_id, slot, new_name):
	var id = "%s_%s" % [peer_id, slot]
	if players.has(id):
		players[id]["name"] = new_name
		_players_data_update.emit()

# Change player to the list for everyone
func Change_name_for_all(peer_id, slot, player_name):
	change_name(peer_id, slot, player_name)
	if GlobalVar.remote_multiplayer_enabled:
		Networking.send_to_others(
				{"type": "change_name", 
				"peer_id": peer_id, 
				"slot": slot,
				"name": player_name})

# Copy new players to the local list
func copy_players(new_list):
	for key in new_list:
		if not players.has(key):
			players[key] = new_list[key]
	_players_data_update.emit()

# Syncs the player list for peers
func sync_players():
	Networking.send_to_others({"type": "players_sync", "list": players})


### SPAWNING PLAYERS
# Spawn a player instance locally
func spawn_player(player):
	var peer_id = player["peer_id"]
	var slot = player["slot"]
	var player_id = "%s_%s" % [peer_id, slot]
	var p = player_scene.instantiate()
	
	p.name = player_id
	p.peer_id = peer_id
	p.player_slot = slot
	p.player_name = player["name"]
	p.set_multiplayer_authority(peer_id)
	
	add_child(p)
	player["instance"] = p


# Spawn all player instances
func spawn_players():
	for player in players:
		spawn_player(player)
