extends Spatial

export(NodePath) var Player

var speed = 5.0

func _process(delta):
	if !Player:
		return

	var node = get_node(Player)

	if Input.is_key_pressed(KEY_W):
		node.translation.z -= speed * delta

	if Input.is_key_pressed(KEY_S):
		node.translation.z += speed * delta

	if Input.is_key_pressed(KEY_A):
		node.translation.x -= speed * delta

	if Input.is_key_pressed(KEY_D):
		node.translation.x += speed * delta
