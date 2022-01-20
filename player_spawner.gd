extends Position2D


var player_scene = preload("res://player.tscn")

func create():
	var player = player_scene.instance()
	# player.get_node("sprite").visible = true
	add_child(player)
	owner.add_child(player)
	print("player created")

func destroy():
	if get_child_count() > 0:
		var player = get_child(0)
		player.queue_free()
		print("player destroyed")
