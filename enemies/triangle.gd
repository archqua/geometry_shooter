extends KinematicBody2D

#export (PackedScene) var bullet

onready var bullet = preload("res://bullet.tscn")

export var bullet_vel = 512
export var max_vel = 512

var lin_vel = Vector2.ZERO
var ang_vel = 0.0

signal shoot
signal switch

enum {
	eup    = 0,
	eright = 1,
	eleft  = 2
}

enum {
	chaotic,
	constant
}

var rotation_mode = chaotic
var movement_mode = chaotic

var state = eup

var third = 2*PI/3

func shoot_to():
	shoot() # emit_signal("shoot")

func shoot():
	var projectile = bullet.instance()
	projectile.add_collision_exception_with(self)
	owner.add_child(projectile)
	projectile.position = position
	# projectile.linear_velocity = Vector2(bullet_vel, 0).rotated(rotation + state*third - PI/2)
	projectile.lin_vel = Vector2(bullet_vel, 0).rotated(rotation + state*third - PI/2)
	## red bullets?
	# projectile.get_child("sprite")

func switch_to():
	switch() # emit_signal("switch")

func switch():
	state = randi() % 3

func collision(collider):
	if collider.has_method("hitEnemy"):
		collider.hitEnemy(self)

func die():
	queue_free()

func hitPlayer(player):
	player.die()
	self.die()

func hitBullet(other_bullet):
	other_bullet.queue_free()
	self.die()

func _ready():
	if $shoot_timer.connect("timeout", self, "shoot_to") != OK:
		print("fail: triangle.shoot_timer.connect(timeout)")
	if $switch_timer.connect("timeout", self, "switch_to") != OK:
		print("fail: triangle.switch_timer.connect(timeout)")

func _physics_process(delta):
	match rotation_mode:
		chaotic:
			ang_vel += rand_range(-1, 1)

		constant:
			pass

	match movement_mode:
		chaotic:
			lin_vel += Vector2(rand_range(-16, 16), rand_range(-16, 16))
		
		constant:
			pass

	rotation += ang_vel * delta
	lin_vel = move_and_slide(lin_vel, Vector2( 0, 0 ), false, 4, 0.785398,
		false)

	for i in get_slide_count():
		var c = get_slide_collision(i)
		collision(c.collider)


