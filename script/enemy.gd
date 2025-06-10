extends baseEntity
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var area_3d: Area3D = $Area3D


var player: baseEntity = null

func _ready() -> void:
	var material = StandardMaterial3D.new()
	var randomColor: Color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	
	
	stats["XP"].value = 100
	stats["SPD"].value = randi_range(100,200) * 2
	player = Main.player
	if !player:
		return
	var EX: int = randi_range(0,20)
	if EX == 20:
		material.metallic_specular = 0.8
	material.albedo_color = randomColor
	mesh_instance_3d.material_override = material
	scale.x = randf_range(0.75, 1.25) *  (1 + player.stats["LVL"].value/10)
	scale.y = randf_range(0.75, 1.25) *  (1 + player.stats["LVL"].value/10)
	scale.y = randf_range(0.75, 1.25) *  (1 + player.stats["LVL"].value/10)
		
func die() -> void:
	Main.changeStat(player, "XP", stats["XP"].value)
	queue_free()

func _physics_process(delta: float) -> void:
	if !player:
		return
	stats["DMG"].value = player.stats["LVL"].value * 50
	var direction = (player.global_position - global_position + Vector3(0,0.5,0)).normalized()
	velocity = (direction * stats["SPD"].value * randf_range(0.75, 1.25) + direction * stats["SPD"].value * player.stats["LVL"].value/25) * delta
	if global_position != player.global_position:
		look_at(player.global_position, Vector3.UP)
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	var target = area.get_parent()
	print(target)
	if player != null and  target == player:
		Main.changeStat(player, "HP", -stats["DMG"].value)
		queue_free()
