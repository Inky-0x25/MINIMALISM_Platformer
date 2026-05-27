extends CharacterBody2D

### Player identifying info
var peer_id = 1
var player_slot = 1
var player_name = ""


### Control keys
var move_left = "move_left_"
var move_right = "move_right_"
var move_up = "move_up_"
var move_down = "move_down_"
var jump = "jump_"
var slide = "slide_"
var dash = "dash_"
var swing = "swing_"
var speed_boost = "speed_boost_"


### State variables
var is_able_to_run : bool = true
var is_able_to_jump : bool = true
var coyote_timer : float = 0.0
var jump_input_buffer_timer : float = 0.0
var jump_key_released : bool = false
var is_double_jump_available : bool = true
var jump_cooldown_timer : float = 0.0
var is_sliding : bool = false
var is_dash_available : bool = true
var dash_direction : Vector2 = Vector2(0, 0)
var facing_direction : float = 1.0 #right
var dash_duration_timer : float = 0
var dash_cooldown_timer : float = 0
var is_wall_sliding : bool = false
var is_climbing : bool = false
var wall_jump_lock_timer : float = 0.0
var is_swinging : bool = false
var swing_anchor : Marker2D = null
@export var swing_max_length : float = 180.0
var swing_length : float = 0
@export var speed_boost_duration : float = 15.0
var speed_boost_duration_timer : float = speed_boost_duration
var normal_stats_profile = preload("res://Entities/Player/Player_stats_profiles/normal_profile.gd").new()
var speed_boosted_stats_profile = preload("res://Entities/Player/Player_stats_profiles/speed_boosted_profile.gd").new()
var stats = normal_stats_profile


func _ready() -> void:
	add_to_group("players")
	### Control mapping
	move_left += str(player_slot)
	move_right += str(player_slot)
	move_up += str(player_slot)
	move_down += str(player_slot)
	jump += str(player_slot)
	slide += str(player_slot)
	dash += str(player_slot)
	swing += str(player_slot)
	speed_boost += str(player_slot)


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		### Speed boost handling
		if Input.is_action_pressed(speed_boost) && speed_boost_duration_timer>0:
			speed_boost_duration_timer -= delta
			stats = speed_boosted_stats_profile
		else:
			stats = normal_stats_profile
		
		
		### Event detect variables
		var direction_x := Input.get_axis(move_left, move_right)
		var direction_y := Input.get_axis(move_up, move_down)
		var on_floor := is_on_floor()
		var on_wall := is_on_wall()
		
		
		### Basic movement ###
		if is_able_to_run:
			# Variables declaration
			var max_speed: float
			var acceleration: float
			var deceleration: float
			var friction_multiplier: float
			
			# Variables setup
			if Input.is_action_pressed(slide) && on_floor:
				is_sliding = true
				max_speed = stats.sliding_run_max_speed
				acceleration = stats.sliding_run_acceleration
				deceleration = stats.sliding_run_deceleration
				friction_multiplier = stats.sliding_friction_ground_multiplier
			else:
				is_sliding = false
				max_speed = stats.run_max_speed
				acceleration = stats.run_acceleration
				deceleration = stats.run_deceleration
				# Friction multiplier
				if on_floor:
					friction_multiplier = stats.friction_ground_multiplier
				else:
					friction_multiplier = stats.friction_air_multiplier
			
			# Movement
			if direction_x != 0:
				facing_direction = direction_x
				velocity.x = move_toward(velocity.x, direction_x * max_speed, acceleration * friction_multiplier * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, deceleration * friction_multiplier * delta)
		
		
		### Jump movement ###
		# Coyote timer and resources refill
		if on_floor:
			coyote_timer = stats.coyote_time
			is_double_jump_available = true
			is_dash_available = true
		else:
			coyote_timer = max(0, coyote_timer-delta)
		
		# Jump buffer
		jump_input_buffer_timer = max(0, jump_input_buffer_timer-delta)
		if Input.is_action_just_pressed(jump):
			jump_input_buffer_timer = stats.jump_input_buffer_time
		
		jump_cooldown_timer = max(0, jump_cooldown_timer-delta)
		
		
		if jump_cooldown_timer == 0 && jump_input_buffer_timer > 0 && is_able_to_jump && not is_swinging:
			if coyote_timer > 0:
				# Jump
				jump_key_released = false
				jump_input_buffer_timer = 0
				coyote_timer = 0
				jump_cooldown_timer = stats.jump_cooldown_time
				velocity.y = -stats.jump_speed
				velocity.x += (sign(velocity.x) * stats.jump_run_speed_boost)
			elif is_climbing or is_wall_sliding:
				jump_key_released = false
				jump_input_buffer_timer = 0
				jump_cooldown_timer = stats.jump_cooldown_time
				var wall_normal = get_wall_normal()
				velocity.x = wall_normal.x * stats.wall_jump_horizontal_speed
				velocity.y = -stats.wall_jump_vertical_speed
			elif is_double_jump_available:
				# Double jump
				jump_key_released = false
				jump_input_buffer_timer = 0
				jump_cooldown_timer = stats.jump_cooldown_time
				is_double_jump_available = false
				velocity.y = -stats.double_jump_speed
				velocity.x += (sign(velocity.x) * stats.double_jump_run_speed_boost)
		
		
		### Dashing handling
		dash_cooldown_timer = max(0, dash_cooldown_timer-delta)
		
		if Input.is_action_just_pressed(dash) && not is_swinging && is_dash_available && dash_cooldown_timer==0:
			is_dash_available = false
			dash_direction = Vector2((direction_x if direction_x else facing_direction), direction_y)
			dash_duration_timer = stats.dash_duration_time
			dash_cooldown_timer = stats.dash_cooldown_time
		
		if dash_duration_timer > 0:
			if dash_duration_timer > delta:
				velocity.x = (dash_direction[0] * stats.dash_horizontal_speed)
				velocity.y = (dash_direction[1] * stats.dash_vertical_speed)
			else:
				velocity.x = (dash_direction[0] * stats.dash_end_horizontal_speed)
				velocity.y *= stats.dash_end_vertical_speed_multiplier
			dash_duration_timer = max(0, dash_duration_timer-delta)
		
		
		### Wall climbing
		if not on_wall or on_floor:
			is_wall_sliding = false
			is_climbing = false
		
		if on_wall:
			var wall_direction = get_wall_normal()
			if direction_x == -wall_direction.x:
				is_climbing = true
				if direction_y != 0:
					velocity.y = move_toward(velocity.y, direction_y * stats.climbing_max_speed, stats.climbing_acceleration * stats.friction_ground_multiplier * delta)
				else:
					velocity.y = move_toward(velocity.y, 0, stats.climbing_deceleration * stats.friction_ground_multiplier * delta)
			else:
				is_climbing = false
		
		if not on_floor:
			if on_wall:
				### Wall sliding
				if direction_x == 0 && not is_climbing:
					is_wall_sliding = true
					velocity.y += (stats.gravity * stats.falling_gravity_multiplier * delta)
					velocity.y = min(velocity.y, stats.wall_slide_speed)
				else:
					is_wall_sliding = false
			else:
				### Gravity
				var gravity_multiplier := 1.0
				
				# Faster fall
				if velocity.y > 0:
					gravity_multiplier *= (stats.falling_gravity_multiplier)
				
				# Short hop
				if Input.is_action_just_released(jump) and velocity.y < 0 && not is_swinging:
					jump_key_released = true
				if jump_key_released:
					gravity_multiplier *= (stats.jump_key_released_gravity_multiplier)
				
				# Falling
				velocity.y += (stats.gravity * gravity_multiplier * delta)
				# Max fall speed
				velocity.y = min(velocity.y, stats.falling_max_speed)
		
		
		### Swinging
		# Start swinging
		if Input.is_action_just_pressed(swing):
			swing_anchor = _get_nearest_swing_point()
			if swing_anchor:
				is_swinging = true
				swing_length = global_position.distance_to(swing_anchor.global_position)
		
		# Swinging movement
		if is_swinging and swing_anchor:
			var anchor_pos = swing_anchor.global_position
			var rope = global_position - anchor_pos
			var rope_dir = rope.normalized()
			
			velocity.y += stats.gravity * delta
			var tangent = Vector2(rope_dir.y, -rope_dir.x)
			var tangent_speed = velocity.dot(tangent)
			
			if direction_x != 0:
				tangent_speed += (direction_x * stats.swing_acceleration * delta)
			else:
				tangent_speed = move_toward(tangent_speed, 0, stats.swing_deceleration * delta)
			tangent_speed = clamp(tangent_speed, -stats.swing_max_speed, stats.swing_max_speed)
			
			velocity = tangent * tangent_speed
			
			global_position = (anchor_pos + rope_dir * swing_length)
			queue_redraw()
		
		# Release swinging
		if is_swinging and Input.is_action_just_released(swing):
			is_swinging = false
			velocity.x *= stats.swing_release_boost
			velocity.y *= stats.swing_release_vertical_speed_multiplier
			swing_anchor = null
		
		move_and_slide()


func _get_nearest_swing_point():
	var nearest = null
	var nearest_distance = INF
	
	for point in get_tree().get_nodes_in_group("swing_points"):
		var d = global_position.distance_to(point.global_position)
		if d < swing_max_length and d < nearest_distance:
			nearest_distance = d
			nearest = point
	
	return nearest


func _draw():
	if is_swinging and swing_anchor:
		draw_line(Vector2.ZERO, to_local(swing_anchor.global_position), Color.WHITE, 2)
