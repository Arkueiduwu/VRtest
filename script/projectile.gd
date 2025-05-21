extends Node3D
@export var damage: int = 100
var source: Node3D = null
@onready var timer : Timer = $Timer

var velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	timer.wait_time = 2

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area)
	if area.get_parent() is baseEntity:
		Main.changeStat(area.get_parent(),"HP", -damage)

func _on_timer_timeout() -> void:
	queue_free()
