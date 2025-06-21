extends baseEntity

signal levelUp
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var enemy_spawner: Node3D = $"../EnemySpawner"

var directional_vector_right: Vector2 = Vector2.ZERO
var directional_vector_left: Vector2 = Vector2.ZERO
var dead_zone_threshold: float = 0.05

var forward: Vector3 = Vector3.ZERO
var right: Vector3 = Vector3.ZERO
var movement_direction: Vector3 = Vector3.ZERO
@onready var cbuster: CharacterBody3D = $XROrigin3D/manoDerecha/cbuster
var grabbing: bool = false
var Rtrigger: bool = false
var Ltrigger: bool = false
var temporalHP: float
var right_grip_pressed: bool = false
var left_grip_pressed: bool = false
var object_in_right_hand: RigidBody3D = null
var object_in_left_hand: RigidBody3D = null
var jumping: bool = false
var crouching: bool = false
@export var crouch_height: float = 0.3
@export var standing_height: float = 1.0
@onready var yippie: PackedScene = load("res://scenes/!!.tscn")

@export var speed: float = 1000
@export var rotation_speed: float = 90.0
@export var gravity: float = 600

@onready var xr_origin: XROrigin3D = $XROrigin3D
@onready var xr_camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var right_hand: XRController3D = $XROrigin3D/manoDerecha
@onready var left_hand: XRController3D = $XROrigin3D/manoIzquierda
@onready var collision_shape_3d: CollisionShape3D = $XROrigin3D/manoIzquierda/LeftHand/Area3D/CollisionShape3D


func _ready():
	Main.player = self
	stats["HP"].value = 1000
	temporalHP = stats["HP"].value

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().current_scene.queue_free()

func _physics_process(delta: float) -> void:
	
	if stats["HP"].value < temporalHP:
		print(stats["HP"].value, temporalHP)
		hurtSound()
	temporalHP = stats["HP"].value
	
	forward = -xr_camera.global_transform.basis.z.normalized()
	right = xr_camera.global_transform.basis.x.normalized()
	forward.y = 0
	right.y = 0
	
	movement_direction = (forward * directional_vector_left.y + right * directional_vector_left.x).normalized()
	velocity = movement_direction * speed * delta
	
	if abs(directional_vector_right.x) > dead_zone_threshold:
		rotate_y(deg_to_rad(-directional_vector_right.x * rotation_speed * delta))
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif jumping and is_on_floor():
		jump()
	jumping = false
	move_and_slide()
	if stats["HP"].value > stats["HP"].max :
		stats["HP"].value = stats["HP"].max
	if stats["XP"].value >= stats["XP"].max:
		onLevelUp()
	if stats["HP"].value <= 0:
		die()
		

### Input Handlers ###
func _on_mano_izquierda_input_vector_2_changed(type: String, value: Vector2) -> void:
	if type == "primary":
		directional_vector_left = value

func _on_mano_derecha_input_vector_2_changed(type: String, value: Vector2) -> void:
	if type == "primary":
		directional_vector_right = value

func _on_mano_izquierda_button_pressed(type: String) -> void:
	if type == "grip_click":
		pass
	if type == "trigger_click":
		Ltrigger = true

func _on_mano_izquierda_button_released(type: String) -> void:
	if type == "grip_click":
		pass

func _on_mano_derecha_button_pressed(type: String) -> void:
	print(type)
	if type == "grip_click":
		pass
	if type == "by_button":
		toggle_crouch()
	if type == "ax_button":
		jumping = true
	if type == "trigger_click":
		cbuster.fire()

func toggle_crouch():
	crouching = !crouching
	xr_origin.position.y = crouch_height if crouching else standing_height
	speed = 500 if crouching else 1000

func onLevelUp():
	stats["XP"].value = 0
	stats["LVL"].value += 1
	stats["XP"].max += 50 * stats["LVL"].value
	print("LVL UP!, current level = ", stats["LVL"].value)
	playLevelUpAnimation()
	levelUp.emit()

func jump():
	velocity.y += 200

func playLevelUpAnimation():
	var yippieInstance = yippie.instantiate()
	add_child(yippieInstance)
	
func die():
	var nodesInWorld = get_tree().current_scene.get_children()
	for i in nodesInWorld:
		if i.is_in_group("enemy"):
			i.queue_free()
	if enemy_spawner:
		enemy_spawner.queue_free()
	Main.perdiste = true


func _on_timer_timeout() -> void:
	stats["HP"].value += 1

func hurtSound():
	audio_stream_player.playing = true

func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area)
	print(cbuster)
	print(cbuster.area_3d)
	if area == cbuster.area_3d and Ltrigger:
		cbuster.reload()
		Ltrigger = false
