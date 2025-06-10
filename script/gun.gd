extends RigidBody3D

### EXPORTS ###
@export var fire_rate: float = 0.1
@export var auto: bool = false
@export var muzzle_velocity: float = 100
@export var damage: int = 25
@export var SFXShooting : String = "res://assets/sounds/762x39 Single WAV.wav"

### NODE REFERENCES ###
@onready var shoot_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var muzzle: RayCast3D = $RayCast3D
@onready var projectileScene: PackedScene = load("res://scenes/projectile.tscn")
@onready var flash: OmniLight3D = $OmniLight3D

### RUNTIME VARIABLES ###
var projectileInstance: Node3D = null
var can_fire: bool = true
var source: Node3D = null
var triggerHeld: bool = false
var player: baseEntity = null
var cooldown_timer: Timer
var flashDuration: Timer
var mag: int = 30
var maxMag: int = 30
func _ready() -> void:
	flash.visible = false
	initialize_weapon()
	cooldown_timer = Timer.new()
	flashDuration = Timer.new()
	add_child(flashDuration)
	add_child(cooldown_timer)
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	flashDuration.timeout.connect(_on_flash_ended)
	

func _process(delta: float) -> void:
	update_trigger_state()
	
	if auto:
		handle_auto_fire()
	else:
		handle_single_fire()

### INITIALIZATION ###
func initialize_weapon() -> void:
	player = get_tree().current_scene.get_node_or_null("player")
	configure_audio()

func configure_audio() -> void:
	shoot_sound.stream = load(SFXShooting)
	shoot_sound.unit_size = 5.0
	shoot_sound.max_distance = 30.0

### INPUT HANDLING ###
func update_trigger_state() -> void:
	triggerHeld = player.Rtrigger if player else false

func handle_auto_fire() -> void:
	if triggerHeld and can_fire:
		fire()

func handle_single_fire() -> void:
	if triggerHeld and can_fire:
		fire()
		can_fire = false  # For single fire, we don't fire again until trigger released

	if not triggerHeld:
		can_fire = true  # Reset for single fire when trigger released

### FIRING MECHANICS ###
func fire() -> void:
	if mag == 0:
		return
	start_fire_cooldown()
	spawn_projectile()
	play_gunshot_sound()
	mag -= 1
	emitFlash()

func start_fire_cooldown() -> void:
	can_fire = false
	cooldown_timer.start(fire_rate)

func _on_cooldown_timeout() -> void:
	can_fire = true

func _on_flash_ended() -> void:
	flash.visible = false

func spawn_projectile() -> void:
	projectileInstance = projectileScene.instantiate()
	get_tree().current_scene.add_child(projectileInstance)
	configure_projectile(projectileInstance)

func configure_projectile(projectile: Node3D) -> void:
	var fire_direction = get_fire_direction()
	
	projectile.global_position = muzzle.global_position
	projectile.velocity = fire_direction * muzzle_velocity
	projectile.damage = damage
	projectile.source = source
	projectile.look_at(projectile.global_position + fire_direction)

func get_fire_direction() -> Vector3:
	var local_direction = muzzle.target_position.normalized()
	return muzzle.global_transform.basis * local_direction

### AUDIO ###
func play_gunshot_sound() -> void:
	if shoot_sound:
		shoot_sound.stop()
		shoot_sound.play()
	else:
		push_warning("AudioStreamPlayer3D missing for gunshot sound")

func emitFlash():
	flash.visible = true
	flashDuration.start(0.05)

func reload():
	if mag != 0:
		return
	mag = maxMag
	
