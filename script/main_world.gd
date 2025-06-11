extends Node3D
@onready var enemy_spawner: Node3D = $EnemySpawner
@onready var ost: String = "res://assets/sounds/05 - Battle 1.mp3"
@onready var audio_stream_player_3d: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var spot_light_3d: SpotLight3D = $SpotLight3D
@onready var player: CharacterBody3D = $player
@export var maxlevel: int = 10
@export var step: float = 0.1

var foggierLOL: bool = false
var foggierLOLCounterLOL: float = 0
func _ready() -> void:
	pass

func _on_player_level_up() -> void:
	foggierLOL = true
	if player.stats["LVL"].value == maxlevel:
		win()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		player.stats["HP"].value = 0
	if foggierLOL:
		world_environment.environment.ambient_light_energy = 0
		if player.stats["LVL"].value >= 4:	
			world_environment.environment.volumetric_fog_enabled = 1
		world_environment.environment.fog_sky_affect = clamp(world_environment.environment.fog_sky_affect + delta/30, 0 , 0.6)
		world_environment.environment.fog_density = clamp(world_environment.environment.fog_density  + delta /30, 0 , 0.6)
		foggierLOLCounterLOL += delta/30
		if foggierLOLCounterLOL >= step:
			foggierLOL = false

func win():
	get_node_or_null("EnemySpawner").queue_free()
	var nodesInWorld = get_children()
	for i in nodesInWorld:
		if i.is_in_group("enemy"):
			i.queue_free()
	enemy_spawner.queue_free()
	Main.ganaste = true
