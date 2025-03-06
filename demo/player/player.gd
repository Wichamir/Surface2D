extends Node2D


func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	const SPEED: float = 500.0
	position += direction * SPEED * delta
