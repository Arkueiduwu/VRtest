extends Sprite2D
var contador: float = 10
func _process(delta: float) -> void:
	contador -= delta
	if contador <= 0:
		queue_free()
