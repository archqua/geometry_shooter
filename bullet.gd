extends KinematicBody2D

var lin_vel = Vector2.ZERO

func hitPlayer(player):
	player.die()
	queue_free()

func hitEnemy(enemy):
	enemy.die()
	queue_free()

func hitBullet(bullet):
	bullet.queue_free()

func imBullet():
	pass

func collision(collider):
	if collider.has_method("imBullet"):
		collider.hitBullet(self)
		self.hitBullet(collider)
	elif collider.has_method("hitBullet"):
		collider.hitBullet(self)


func _physics_process(delta):
	lin_vel = move_and_slide(lin_vel, Vector2( 0, 0 ), false, 4, 0.785398,
		false)

	for i in get_slide_count():
		var c = get_slide_collision(i)
		collision(c.collider)
