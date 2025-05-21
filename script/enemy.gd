extends baseEntity

@onready var player: baseEntity = get_node_or_null("../player")

func _ready() -> void:
	stats["XP"].value = 100
	if !player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

func die() -> void:
	Main.changeStat(player, "XP", stats["XP"].value)
	queue_free()

func _physics_process(delta: float) -> void:
	if !player:
		return
	
	# Cálculo de movimiento mejorado
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * stats["SPD"].value * delta
	if global_position != player.global_position:
		look_at(player.global_position, Vector3.UP)
	move_and_slide()
