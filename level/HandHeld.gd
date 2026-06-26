extends StaticBody

class_name HandHeld

var highlight_material : SpatialMaterial

func get_hand_anchor(for_controller) -> Transform:
	if for_controller == 1:
		return $LeftHandAnchor.global_transform
	if for_controller == 2:
		return $RightHandAnchor.global_transform
	
	return Transform()

func _ready():
	highlight_material = SpatialMaterial.new()
	highlight_material.albedo_color = Color(1.0, 1.0, 0.5)
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(0.8, 0.8, 0.2)

func highlight():
	var mesh1 = get_node_or_null("Base/Mesh1")
	if mesh1:
		mesh1.set_surface_material(0, highlight_material)

func unhighlight():
	var mesh1 = get_node_or_null("Base/Mesh1")
	if mesh1:
		mesh1.set_surface_material(0, null)

