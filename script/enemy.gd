extends CharacterBody3D

@export var HP: float = 10.0
@export var speed: float = 100.0  # Valor más manejable que 10000
@export var XPonKill: float = 33.4

@onready var player: CharacterBody3D = get_node_or_null("../player")

func _ready() -> void:
	# Mejor manera de encontrar al jugador
	if !player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

func change_stat(type: String, amount: float) -> void:
	match type:
		"HP":
			HP += amount
			if HP <= 0:
				die()

func die() -> void:
	# Aquí podrías añadir efectos de muerte o XP al jugador
	if player and player.has_method("gain_xp"):
		player.gain_xp(XPonKill)
	queue_free()

func _physics_process(delta: float) -> void:
	if !player:
		return
	
	# Cálculo de movimiento mejorado
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed * delta
	
	# Rotación hacia el jugador
	look_at(player.global_position, Vector3.UP)
	
	# Movimiento suave con move_and_slide()
	move_and_slide()
