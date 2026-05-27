extends Resource

### Basic movement variables
@export var run_max_speed : float = 400.0
@export var run_acceleration : float = 2000.0
@export var run_deceleration : float = 3000.0

@export var friction_ground_multiplier : float = 1.2
@export var friction_air_multiplier : float = 0.85


### Jump related variables
@export var coyote_time : float = 0.1
@export var jump_input_buffer_time : float = 0.1

@export var jump_speed : float = 500.0
@export var jump_run_speed_boost : float = 200.0

@export var falling_max_speed : float = 800.0
@export var falling_gravity_multiplier : float = 2
@export var jump_key_released_gravity_multiplier : float = 2.5
@export var gravity : float = 1200.0


### Double jump related variables
@export var jump_cooldown_time : float = 0.1
@export var double_jump_speed : float = jump_speed
@export var double_jump_run_speed_boost : float = jump_run_speed_boost


### Sliding related variables
@export var sliding_run_max_speed : float = 720
@export var sliding_run_acceleration : float = 1600
@export var sliding_run_deceleration : float = 1200
@export var sliding_friction_ground_multiplier : float = 0.8


### Dash related variables
@export var dash_horizontal_speed : float = 1400
@export var dash_vertical_speed : float = 1000
@export var dash_end_horizontal_speed : float = 300
@export var dash_end_vertical_speed_multiplier : float = 0.15

@export var dash_duration_time : float = 0.1
@export var dash_cooldown_time : float = 0.3


### Wall sliding related variables
@export var wall_slide_speed : float = 500


### Climbing related variables
@export var climbing_max_speed : float = 300
@export var climbing_acceleration : float = 1800
@export var climbing_deceleration : float = 3000


### Wall jump related variables
@export var wall_jump_vertical_speed : float = jump_speed * 0.8
@export var wall_jump_horizontal_speed : float = 800

@export var wall_jump_control_lock : float = 0.15


### Swinging related variables
@export var swing_max_speed : float = 600.0
@export var swing_acceleration : float = 1400.0
@export var swing_deceleration : float = 100.0
@export var swing_release_boost : float = 1.6
@export var swing_release_vertical_speed_multiplier : float = 1.0
