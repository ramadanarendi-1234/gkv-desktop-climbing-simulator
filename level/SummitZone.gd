extends Area

signal summit_reached

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	emit_signal("summit_reached")
