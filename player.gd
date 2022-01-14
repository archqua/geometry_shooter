extends KinematicBody2D

export var max_vel = 1024
export var accel_time = 0.2
var max_accel = max_vel/accel_time
var decay = 1/accel_time

var accel = Vector2.ZERO
var lin_vel = Vector2.ZERO

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	rotation = position.angle_to_point(mouse_pos) - PI/2
	
	var input_accel = Vector2.ZERO
	input_accel.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_accel.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var old_accel = accel
	accel = max_accel * input_accel.normalized().rotated(rotation)  -  decay * lin_vel
	var old_lin_vel = lin_vel
	lin_vel += 0.5*delta*(old_accel + accel)
	
	position += 0.5*delta*(old_lin_vel + lin_vel)
	
