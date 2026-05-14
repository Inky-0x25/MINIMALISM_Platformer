extends Node

var host_id = 1
var local_ip = ""
var public_ip = ""
var connected_ip = ""
var port = 9999

signal message_received(data)



func _ready():
	# connecting signals with functions
	message_received.connect(_on_network_message)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connection_to_server)
	multiplayer.server_disconnected.connect(_on_disconnection_from_server)


### NETWORK FUNCTIONS
# Return the local id
func get_local_id():
	return multiplayer.get_unique_id()

# Return the local ip
func get_local_ipv4():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return ""

# Return the public ip
func get_public_ip() -> String:
	var http = HTTPRequest.new()
	add_child(http)
	var err = http.request("https://api.ipify.org")
	if err == OK:
		var result = await http.request_completed
		http.queue_free()
		return result[3].get_string_from_utf8()
	else:
		return ""

# Validate ip address
func is_valid_ip(ip: String) -> bool:
	if ip == "":
		return false
	var result = IP.resolve_hostname(ip)
	return result.length() > 0

# Start hosting
func host_game():
	if not GlobalVar.remote_multiplayer_enabled:
		var peer = ENetMultiplayerPeer.new()
		var result = peer.create_server(port)
		
		if result == OK:
			multiplayer.multiplayer_peer = peer
			GlobalVar.remote_multiplayer_enabled = true
			local_ip = get_local_ipv4()
			public_ip = await get_public_ip()
			print("Hosting on port ", port)
			return true
		else:
			print("Failed to host")
			return false

# Joining
func join_game(ip):
	if not GlobalVar.remote_multiplayer_enabled:
		if is_valid_ip(ip):
			var peer = ENetMultiplayerPeer.new()
			var result = peer.create_client(ip, port)
			
			if result == OK:
				multiplayer.multiplayer_peer = peer
				GlobalVar.remote_multiplayer_enabled = true
				connected_ip = ip
				print("Connecting to ", ip)
				return true
			else:
				print("Failed to join")
				return false
		else:
			print("Invalid ip: " + ip)

# Disconnecting
func disconnect_game():
	if GlobalVar.remote_multiplayer_enabled:
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		GlobalVar.remote_multiplayer_enabled = false
		local_ip = ""
		public_ip = ""
		connected_ip = ""
		PlayersManager.remove_all_remote_players()
		print("Disconnected")


### TRANSMITION FUNCTIONS
# Send package
func send(peer_id, data):
	_receive_data.rpc_id(peer_id, data)

# Send to the server
func send_to_server(data):
	_receive_data.rpc_id(host_id, data)

func send_to_peers(data):
	for id in multiplayer.get_peers():
		send(id, data)

# Send to all other players
func send_to_others(data):
	if not multiplayer.is_server():
		send_to_server(data)
	send_to_peers(data)

# Send to all except one
func send_except(peer_id, data):
	if not multiplayer.is_server() && peer_id != host_id:
		send_to_server(data)
	for id in multiplayer.get_peers():
		if id != peer_id:
			send(id, data)

# Receive package
@rpc("any_peer")
func _receive_data(data):
	emit_signal("message_received", data)

# Handle messages
func _on_network_message(data):
	if data.has("type"):
		match data["type"]:
			"add_player":
				PlayersManager.add_player(data["peer_id"], data["slot"], data["name"])
			"remove_player":
				PlayersManager.remove_player(data["peer_id"], data["slot"])
			"change_name":
				PlayersManager.change_name(data["peer_id"], data["slot"], data["name"])
			"players_sync":
				PlayersManager.copy_players(data["list"])
			"spawn_players":
				PlayersManager.spawn_players()


### SIGNAL FUNCTIONS
func _on_peer_connected(id):
	print("[%s]-Peer connected: %s" % [get_local_id(), id])
	if multiplayer.is_server():
		send(id, {"type": "players_sync", "list": PlayersManager.players})

func _on_peer_disconnected(id):
	print("Peer disconnected:", id)
	PlayersManager.remove_peer(id)

func _on_connection_to_server():
	print("Connected to the server")

func _on_disconnection_from_server():
	print("Disconnected from server")
