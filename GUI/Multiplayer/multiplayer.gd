extends Control

@onready var enable_second_player_button = $MarginContainer/VBoxContainer/HBoxContainer/MultiplayerContainer/LocalMultiplayerContainer/Player2Container/Player2Enabled
@onready var player_1_name_edit = $MarginContainer/VBoxContainer/HBoxContainer/MultiplayerContainer/LocalMultiplayerContainer/Player1Container/Player1NameEdit
@onready var player_2_name_edit = $MarginContainer/VBoxContainer/HBoxContainer/MultiplayerContainer/LocalMultiplayerContainer/Player2Container/Player2NameEdit
@onready var player_1_info = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/ScrollContainer/PlayerListContainer/Player1InfoContainer
@onready var player_2_info = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/ScrollContainer/PlayerListContainer/Player2InfoContainer
@onready var player_1_name = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/ScrollContainer/PlayerListContainer/Player1InfoContainer/PlayerName
@onready var player_2_name = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/ScrollContainer/PlayerListContainer/Player2InfoContainer/PlayerName
@onready var player_1_id = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/ScrollContainer/PlayerListContainer/Player1InfoContainer/PlayerID
@onready var player_2_id = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/ScrollContainer/PlayerListContainer/Player2InfoContainer/PlayerID
@onready var host_button = $MarginContainer/VBoxContainer/HBoxContainer/MultiplayerContainer/HostContainer/HostButton
@onready var localIP = $MarginContainer/VBoxContainer/HBoxContainer/MultiplayerContainer/HostContainer/LocalIPContainer/LocalIP
@onready var publicIP = $MarginContainer/VBoxContainer/HBoxContainer/MultiplayerContainer/HostContainer/PublicIPContainer/PublicIP
@onready var join_button = $MarginContainer/VBoxContainer/HBoxContainer/MultiplayerContainer/JoinContainer/JoinButton
@onready var ip_to_join = $MarginContainer/VBoxContainer/HBoxContainer/MultiplayerContainer/JoinContainer/IP_to_joinContainer/IP_to_join
@onready var room_player_list = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/ScrollContainer/PlayerListContainer
@onready var disconnect_button = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/RoomActionsContainer/DisconnectButton
@onready var start_button = $MarginContainer/VBoxContainer/HBoxContainer/RoomContainer/RoomActionsContainer/StartButton
@onready var back_button = $MarginContainer/VBoxContainer/Back



func _ready():
	_ui_update()
	# Connecting signals with functions
	enable_second_player_button.toggled.connect(_on_second_player_state_changed)
	player_1_name_edit.focus_exited.connect(_on_name_submitted.bind("", player_1_name, player_1_name_edit, 1))
	player_2_name_edit.focus_exited.connect(_on_name_submitted.bind("", player_2_name, player_2_name_edit, 2))
	player_1_name_edit.text_submitted.connect(_on_name_submitted.bind(player_1_name, player_1_name_edit, 1))
	player_2_name_edit.text_submitted.connect(_on_name_submitted.bind(player_2_name, player_2_name_edit, 2))
	host_button.pressed.connect(_on_hosting)
	join_button.pressed.connect(_on_joining)
	multiplayer.connected_to_server.connect(_on_connection_to_server)
	disconnect_button.pressed.connect(_on_disconnect)
	multiplayer.server_disconnected.connect(_on_disconnect)
	GlobalNav.link_button_to_scene(start_button, "res://GUI/Singleplayer/Singleplayer.tscn")
	PlayersManager._players_data_update.connect(_ui_update)
	back_button.pressed.connect(_on_back)

# Trigger when the second player is enabled or disabled
func _on_second_player_state_changed(state):
	player_2_name_edit.editable = state
	player_2_info.visible = state
	GlobalVar.local_multiplayer_enabled = state
	if state:
		player_2_name_edit.focus_mode = FOCUS_ALL
		PlayersManager.local_player_count = 2
		PlayersManager.add_player_for_all(Networking.get_local_id(), 2, "")
	else:
		player_2_name_edit.text = ""
		player_2_name.text = "@menu_unnamed@"
		player_2_name_edit.focus_mode = FOCUS_NONE
		PlayersManager.local_player_count = 1
		PlayersManager.remove_player_for_all(Networking.get_local_id(), 2)
	update_start_button_state()

# Trigger on name submission
func _on_name_submitted(_new_text, player_name, name_edit, slot):
	if name_edit.text == "":
		player_name.text = "@menu_unnamed@"
	else:
		player_name.text = name_edit.text
	PlayersManager.Change_name_for_all(Networking.get_local_id(), slot, name_edit.text)

# Change the ui element activity state
func change_ui_element_state(element, state):
	if element.get("disabled") != null:
		element.disabled = not state
	if element.get("editable") != null:
		element.editable = state
	if state:
		element.focus_mode = FOCUS_ALL
	else:
		element.focus_mode = FOCUS_NONE

# Update start button state
func update_start_button_state():
	var start_button_status
	if GlobalVar.remote_multiplayer_enabled:
		start_button_status = multiplayer.is_server()
	else:
		start_button_status = GlobalVar.local_multiplayer_enabled
	start_button.disabled = not start_button_status
	if start_button_status:
		start_button.focus_mode = FOCUS_ALL
	else:
		start_button.focus_mode = FOCUS_NONE

# Change gui state
func change_ui_mode(mode):
	change_ui_element_state(host_button, mode)
	change_ui_element_state(join_button, mode)
	change_ui_element_state(ip_to_join, mode)
	change_ui_element_state(back_button, mode)
	change_ui_element_state(disconnect_button, not mode)
	update_start_button_state()

# Trigger when host button is pressed
func _on_hosting():
	if not GlobalVar.remote_multiplayer_enabled:
		var result = await Networking.host_game()
		if result:
			localIP.text = Networking.local_ip
			publicIP.text = Networking.public_ip
			change_ui_mode(false)
			
			PlayersManager.add_player(Networking.get_local_id(), 1, player_1_name_edit.text)
			if GlobalVar.local_multiplayer_enabled:
				PlayersManager.add_player(Networking.get_local_id(), 2, player_2_name_edit.text)

# Trigger when join button is pressed
func _on_joining():
	if not GlobalVar.remote_multiplayer_enabled:
		var result = Networking.join_game(ip_to_join.text)
		if result:
			change_ui_mode(false)

# Trigger when connected to the server
func _on_connection_to_server():
		PlayersManager.add_player_for_all(Networking.get_local_id(), 1, player_1_name.text)		
		if GlobalVar.local_multiplayer_enabled:
			PlayersManager.add_player_for_all(Networking.get_local_id(), 2, player_2_name.text)

# Trigger when disconnect button is pressed
func _on_disconnect():
	Networking.disconnect_game()
	change_ui_mode(true)

# Trigger when turning back to main menu
func _on_back():
	_on_second_player_state_changed(false)
	GlobalNav.change_scene("res://GUI/Main/Main.tscn")

# Triggered when players data is modify with functions
func _ui_update():
	# UI state update
	localIP.text = Networking.local_ip
	publicIP.text = Networking.public_ip
	ip_to_join.text = Networking.connected_ip
	change_ui_mode(not GlobalVar.remote_multiplayer_enabled)
	enable_second_player_button.button_pressed = GlobalVar.local_multiplayer_enabled
	_on_second_player_state_changed(GlobalVar.local_multiplayer_enabled)
	
	# Local players update
	var local_id = str(Networking.get_local_id())
	player_1_id.text = local_id + "_1"
	player_2_id.text = local_id + "_2"
	if PlayersManager.players.has(player_1_id.text):
		player_1_name_edit.text = PlayersManager.players[player_1_id.text]["name"]
	if PlayersManager.players.has(player_2_id.text):
		player_2_name_edit.text = PlayersManager.players[player_2_id.text]["name"]
	if player_1_name_edit.text == "":
		player_1_name.text = "@menu_unnamed@"
	else:
		player_1_name.text = player_1_name_edit.text
	if player_2_name_edit.text == "":
		player_2_name.text = "@menu_unnamed@"
	else:
		player_2_name.text = player_2_name_edit.text
	
	# Room list update
	for playerContainer in room_player_list.get_children():
		if playerContainer.get_node("PlayerID")!=player_1_id and playerContainer.get_node("PlayerID")!=player_2_id:
			playerContainer.queue_free()
	for key in PlayersManager.players:
		var p = PlayersManager.players[key]
		if p["peer_id"] != Networking.get_local_id():
			var new_player_id = str(p["peer_id"]) + "_" + str(p["slot"])
			var new_player_info = player_1_info.duplicate()
			new_player_info.name = new_player_id + "InfoContainer"
			if p["name"] == "":
				new_player_info.get_node("PlayerName").text = "@menu_unnamed@"
			else:
				new_player_info.get_node("PlayerName").text = p["name"]
			new_player_info.get_node("PlayerID").text = new_player_id
			room_player_list.add_child(new_player_info)
