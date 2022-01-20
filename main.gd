extends Node

#export (PackedScene) var player
#export (PackedScene) var triangle

onready var esl = $enemy_spawn_path/enemy_spawn_location
onready var Triangle = preload("res://enemies/triangle.tscn")
onready var Player = preload("res://player.tscn")

# var player: Node

func _ready():
	if $enemy_spawn_timer.connect("timeout", self, "spawnEnemy") != OK:
		print("fail: main.enemy_spawn_timer.connect(timeout)")
	if $start_button.connect("button_down", self, "spawnPlayer") != OK:
		print("fail: main.start_button.connect(button_down)")


func playerHit(player):
	print("hit!")
	if is_instance_valid(player):
		player.die()

func playerFire(player):
	print("fire!")
	if is_instance_valid(player):
		player.fire()

func playerDeath(player):
	print("death!")
	if is_instance_valid(player):
		player.deactivate()
		disconnectPlayerSignals(player)

func connectPlayerSignals(player):
	if player.connect("death", self, "playerDeath") != OK:
		print("fail: main.player.connect(death)")
	if player.connect("hit", self, "playerHit") != OK:
		print("fail: main.player.connect(hit)")
	# if $player_connect_fire_timer.connect("timeout", self, "playerConnectFire", [player]) != OK:
		# print("fail: main.player_connect_fire_timer.connect(timeout)")
	# $player_connect_fire_timer.start()
	playerConnectFire(player)

func disconnectPlayerSignals(player):
	if player.is_connected("death", self, "playerDeath"):
		player.disconnect("death", self, "playerDeath")
	if player.is_connected("hit", self, "playerHit"):
		player.disconnect("hit", self, "playerHit")
	if $player_connect_fire_timer.is_connected("timeout", self, "playerConnectFire"):
		$player_connect_fire_timer.disconnect("timeout", self, "playerConnectFire")
	if player.is_connected("fire", self, "playerFire"):
		player.disconnect("fire", self, "playerFire")

func spawnEnemy():
	esl.offset = randi()
	var mob = Triangle.instance()
	add_child(mob)
	mob.set_owner(self)
	var direction = esl.rotation + PI/2
	mob.position = esl.position
	direction += rand_range(-PI/4, PI/4)
	mob.rotation = direction
	#mob.lin_vel = Vector2(tau(rand_range(0, 1)), 0)
	mob.lin_vel = mob.lin_vel.rotated(direction)
	#score += 1
	#$hud.updateScore(score)

func playerConnectFire(_player):
	if is_instance_valid(_player) and _player.connect("fire", self, "playerFire") != OK:
		print("fail: main.player.connect(fire)")

func spawnPlayer():
	$player_connect_fire_timer.stop()
	if $player_spawner.get_child_count() == 0:
		$player_spawner.create()
	var player = $player_spawner.get_child(0)
	add_child(player)
	player.set_owner(self)
	connectPlayerSignals(player)
	player.position = Vector2(512, 1024-256)
	player.activate()
	$enemy_spawn_timer.start() # TOCORRECT
