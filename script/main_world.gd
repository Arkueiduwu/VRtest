extends Node3D
@onready var enemy_spawner: Node3D = $EnemySpawner
@onready var ost: String = "res://assets/sounds/05 - Battle 1.mp3"
@onready var audio_stream_player_3d: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var spot_light_3d: SpotLight3D = $SpotLight3D
@onready var player: CharacterBody3D = $player
@export var maxlevel: int = 10
func _ready() -> void:
	pass

func _on_player_level_up() -> void:
	world_environment.environment.fog_density += 0.02
	if player.stats["LVL"].value == maxlevel:
		win()

func win():
	get_node_or_null("EnemySpawner").queue_free()
	var nodesInWorld = get_children()
	for i in nodesInWorld:
		if i.is_in_group("enemy"):
			i.queue_free()
	enemy_spawner.queue_free()
	Main.ganaste = true
	
