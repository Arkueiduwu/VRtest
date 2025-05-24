extends baseEntity
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

var player: baseEntity = null

func _ready() -> void:
	var material = StandardMaterial3D.new()
	var randomColor: Color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	material.albedo_color = randomColor
	mesh_instance_3d.material_override = material
	stats["XP"].value = 100

func die() -> void:
	Main.changeStat(player, "XP", stats["XP"].value)
	queue_free()

func _physics_process(delta: float) -> void:
	player = Main.player
	if !player:
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * stats["SPD"].value * delta
	if global_position != player.global_position:
		look_at(player.global_position, Vector3.UP)
	move_and_slide()
