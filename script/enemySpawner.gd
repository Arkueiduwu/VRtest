# EnemySpawner.gd
extends Node3D  # O Marker3D si solo es un punto de referencia

@export var enemy_scene: PackedScene
@export var spawn_delay: float = 2.0
@export var spawn_area_radius: float = 48.0
@export var max_enemies: int = 10 

var current_enemies: int = 0
var spawn_timer: float = 0.0

func _ready():
	if !enemy_scene:
		enemy_scene = load("res://scenes/enemy.tscn")

func _physics_process(delta: float):
	if current_enemies >= max_enemies:
		return
	
	spawn_timer += delta
	if spawn_timer >= spawn_delay:
		spawn_enemy()
		spawn_timer = 0.0

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)  # Añade al padre del spawner (ej: el mundo)
	
	
	var random_angle = randf_range(0, TAU)
	var random_radius = randf_range(0, spawn_area_radius)
	enemy.global_position = global_position + Vector3(
		cos(random_angle) * random_radius,
		0.0,
		sin(random_angle) * random_radius
	)
	
	current_enemies += 1
	enemy.tree_exited.connect(_on_enemy_destroyed.bind())

func _on_enemy_destroyed():
	current_enemies -= 1  # Libera espacio para nuevos enemigos
