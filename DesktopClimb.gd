extends Spatial

var climb_distance = 3.0

func _process(delta):

	if Input.is_key_pressed(KEY_E):

		var player = get_parent().get_node("Player")
		var handholds = get_parent().get_node("Mountain/HandHelds")

		var closest = null
		var closest_distance = 999999

		for h in handholds.get_children():

			var dist = player.global_transform.origin.distance_to(
				h.global_transform.origin
			)

			if dist < closest_distance:
				closest_distance = dist
				closest = h

		if closest and closest_distance < climb_distance:

			player.global_transform.origin = closest.global_transform.origin + Vector3(0, -1, 0)
