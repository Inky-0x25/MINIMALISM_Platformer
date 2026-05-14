extends CharacterBody2D

var peer_id = 1
var player_slot = 1
var player_name = ""

@export var move_speed = 220.0
@export var acceleration = 1400.0
@export var friction = 1800.0

@export var jump_force = -380.0
@export var gravity = 1000.0
@export var fall_gravity_multiplier = 1.7

@export var coyote_time = 0.12
@export var jump_buffer_time = 0.12

var coyote_timer = 0.0
var jump_buffer_timer = 0.0
