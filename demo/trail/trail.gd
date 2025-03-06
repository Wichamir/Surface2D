extends Line2D


const MAX_LENGTH := 20


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var _points: Array = points
	_points.push_front(owner.global_position)
	while _points.size() > MAX_LENGTH:
		_points.pop_back()
	
	points = _points

