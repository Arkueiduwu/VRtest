extends Node3D
@export var damage: float = 10.0
@export var lifetime: float = 3.0
var source: Node3D = null

var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("change_stat"):
		body.change_stat("HP", -damage)
		source.change_stat("XP", body.XPonKill)
