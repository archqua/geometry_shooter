extends KinematicBody2D

export (PackedScene) var bullet

export var max_vel = 1024
export var accel_time = 0.1
export var bullet_vel = 1024
export var dry_friction = 1280/8

signal fire(this)
signal hit(this)
signal death(this)

var max_accel = max_vel/accel_time
var decay = 1/accel_time

var accel = Vector2.ZERO
var lin_vel = Vector2.ZERO

func hitBullet(bullet):
	self.die()
	bullet.queue_free()

func hitEnemy(enemy):
	self.die()
	enemy.die()

func collision(collider):
	# print("collided w/ ", collider.name)
	if collider.has_method("hitPlayer"):
		emit_signal("hit", self)
		collider.hitPlayer(self)

func fire():
	var projectile = bullet.instance()
	projectile.add_collision_exception_with(self)
	owner.add_child(projectile)
	var mouse_pos = get_viewport().get_mouse_position()
	projectile.position = position
	# projectile.linear_velocity = Vector2(bullet_vel, 0).rotated(position.angle_to_point(mouse_pos) + PI)
	projectile.lin_vel = Vector2(bullet_vel, 0).rotated(position.angle_to_point(mouse_pos) + PI)

func die():
	emit_signal("death", self)

func activate():
	$sprite.visible = true
	$hitbox.disabled = false

func deactivate():
	$sprite.visible = false
	$hitbox.disabled = true

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	rotation = position.angle_to_point(mouse_pos) - PI/2
	
	var input_accel = Vector2.ZERO
	input_accel.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_accel.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var old_accel = accel
	accel = (max_accel + dry_friction) * input_accel.normalized().rotated(rotation)  -\
				decay * lin_vel  -  dry_friction * lin_vel.normalized()
	var old_lin_vel = lin_vel
	lin_vel += 0.5*delta*(old_accel + accel)
	
	lin_vel = move_and_slide(0.5*(old_lin_vel + lin_vel),
		Vector2( 0, 0 ), false, 4, 0.785398,
		false
		)
	for i in get_slide_count():
		var c = get_slide_collision(i)
		collision(c.collider)
	
	if Input.is_action_just_pressed("ui_fire"):
		emit_signal("fire", self)
