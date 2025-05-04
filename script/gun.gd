extends RigidBody3D

@onready var shoot_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var projectileScene: PackedScene = load("res://scenes/projectile.tscn")
var projectileInstance: Node3D = null
@export var fire_rate: float = 0.2 
@export var muzzle_velocity: float = 177.0
@export var damage: float = 10.0
var can_fire: bool = true
@onready var muzzle: RayCast3D = $RayCast3D
var source: Node3D = null

func _ready() -> void:
	# Configuración inicial del sonido
	shoot_sound.stream = load("res://assets/sounds/762x39 Single WAV.wav")  # Asegúrate de tener este archivo
	shoot_sound.unit_size = 5.0  # Ajusta según necesidad
	shoot_sound.max_distance = 30.0
	
func fire() -> void:
	if not can_fire:
		return
		
	can_fire = false
	get_tree().create_timer(fire_rate).timeout.connect(func(): can_fire = true)
	
	# Instanciar proyectil
	projectileInstance = projectileScene.instantiate()
	get_tree().current_scene.add_child(projectileInstance)

	# Cálculo de dirección
	var local_direction = muzzle.target_position.normalized()
	var global_direction = muzzle.global_transform.basis * local_direction
	
	# Configurar proyectil
	projectileInstance.global_position = muzzle.global_position
	projectileInstance.velocity = global_direction * muzzle_velocity
	projectileInstance.damage = damage
	projectileInstance.source = source
	projectileInstance.look_at(projectileInstance.global_position + global_direction)
	
	# Reproducir sonido
	play_gunshot_sound()

func play_gunshot_sound() -> void:
	if shoot_sound:
		shoot_sound.stop()  # Detener cualquier sonido previo
		shoot_sound.play()  # Reproducir el sonido
	else:
		push_warning("No se encontró AudioStreamPlayer3D para el sonido de disparo")
