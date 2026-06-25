extends Spatial

export(NodePath) var player_path
export(NodePath) var camera_path

var sensitivity = 0.003

var player
var camera

func _ready():
	player = get_node(player_path)
	camera = get_node(camera_path)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:

		player.rotation.y -= event.relative.x * sensitivity

		camera.rotation.x -= event.relative.y * sensitivity

		camera.rotation.x = clamp(
			camera.rotation.x,
			deg2rad(-80),
			deg2rad(80)
		)
