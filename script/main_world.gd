extends Node3D

@onready var ost: String = "res://assets/sounds/05 - Battle 1.mp3"
@onready var audio_stream_player_3d: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var spot_light_3d: SpotLight3D = $SpotLight3D
@onready var player: CharacterBody3D = $player

func _ready() -> void:
	pass
	


func _on_player_level_up() -> void:
	world_environment.environment.fog_density += 0.02
	if player.stats["LVL"].value == 7:
		win()

func win():
	get_tree().quit(0)
