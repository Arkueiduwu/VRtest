extends baseEntity

signal levelUp
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var directional_vector_right: Vector2 = Vector2.ZERO
var directional_vector_left: Vector2 = Vector2.ZERO
var dead_zone_threshold: float = 0.05

var forward: Vector3 = Vector3.ZERO
var right: Vector3 = Vector3.ZERO
var movement_direction: Vector3 = Vector3.ZERO

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
@export var throw_force: float = 1.5

@onready var xr_origin: XROrigin3D = $XROrigin3D
@onready var xr_camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var right_hand: XRController3D = $XROrigin3D/manoDerecha
@onready var left_hand: XRController3D = $XROrigin3D/manoIzquierda
@onready var right_grab_area: Area3D = $XROrigin3D/manoDerecha/grabAreaR
@onready var left_grab_area: Area3D = $XROrigin3D/manoIzquierda/grabAreaL

@onready var right_hand_attachment: Marker3D = $XROrigin3D/manoDerecha/AttachmentPoint
@onready var left_hand_attachment: Marker3D = $XROrigin3D/manoIzquierda/AttachmentPoint

var previous_positions = {}

func _ready():
	Main.player = self
	stats["HP"].value = 1000
	temporalHP = stats["HP"].value
	assert(right_hand_attachment != null, "Right hand attachment missing!")
	assert(left_hand_attachment != null, "Left hand attachment missing!")
	assert(right_grab_area != null, "Right grab area missing!")
	assert(left_grab_area != null, "Left grab area missing!")

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
	
	update_held_objects()
	if stats["HP"].value > stats["HP"].max :
		stats["HP"].value = stats["HP"].max
	if stats["XP"].value >= stats["XP"].max:
		onLevelUp()
	if stats["HP"].value <= 0:
		die()
		

func update_held_objects():
	if object_in_right_hand and is_instance_valid(object_in_right_hand):
		var obj_attachment = object_in_right_hand.find_child("AttachmentPoint")
		if obj_attachment:
			# Calcular offset para mantener la posición relativa del punto de agarre
			var offset = object_in_right_hand.global_transform.origin - obj_attachment.global_transform.origin
			object_in_right_hand.global_transform.origin = right_hand_attachment.global_transform.origin + offset
			
			# Para armas alinear con la rotación de la mano
			if object_in_right_hand.is_in_group("gun"):
				object_in_right_hand.global_rotation = right_hand.global_rotation
			else:
				object_in_right_hand.global_transform.basis = right_hand_attachment.global_transform.basis
		else:
			# Sin punto de agarre, usar el centro de "masa"
			object_in_right_hand.global_transform = right_hand_attachment.global_transform
	
	if object_in_left_hand and is_instance_valid(object_in_left_hand):
		var obj_attachment = object_in_left_hand.find_child("AttachmentPoint")
		if obj_attachment:
			var offset = object_in_left_hand.global_transform.origin - obj_attachment.global_transform.origin
			object_in_left_hand.global_transform.origin = left_hand_attachment.global_transform.origin + offset
			
			if object_in_left_hand.is_in_group("gun"):
				object_in_left_hand.global_rotation = left_hand.global_rotation
			else:
				object_in_left_hand.global_transform.basis = left_hand_attachment.global_transform.basis
		else:
			object_in_left_hand.global_transform = left_hand_attachment.global_transform

### Input Handlers ###
func _on_mano_izquierda_input_vector_2_changed(type: String, value: Vector2) -> void:
	if type == "primary":
		directional_vector_left = value

func _on_mano_derecha_input_vector_2_changed(type: String, value: Vector2) -> void:
	if type == "primary":
		directional_vector_right = value

func _on_mano_izquierda_button_pressed(type: String) -> void:
	if type == "grip_click":
		left_grip_pressed = true
		try_grab_left()

func _on_mano_izquierda_button_released(type: String) -> void:
	if type == "grip_click":
		left_grip_pressed = false
		release_left()
	if type == "by_button":
		
		jumping = true	

func _on_mano_derecha_button_pressed(type: String) -> void:
	if type == "grip_click":
		right_grip_pressed = true
		try_grab_right()
	if type == "by_button":
		toggle_crouch()
	if type == "trigger_click" and object_in_right_hand != null:
		Rtrigger = true

func _on_mano_derecha_button_released(type: String) -> void:
	if type == "grip_click":
		right_grip_pressed = false
		release_right()
	if type == "trigger_click" and object_in_right_hand != null:
		Rtrigger = false

func toggle_crouch():
	crouching = !crouching
	xr_origin.position.y = crouch_height if crouching else standing_height
	speed = 500 if crouching else 1000

### Grabbing System ###
func try_grab_left():
	if object_in_left_hand != null: return
	
	for body in left_grab_area.get_overlapping_bodies():
		if body.is_in_group("grabbable") and body is RigidBody3D:
			grab_object(body, left_hand_attachment)
			object_in_left_hand = body
			break

func try_grab_right():
	if object_in_right_hand != null: return
	
	for body in right_grab_area.get_overlapping_bodies():
		if body.is_in_group("grabbable") and body is RigidBody3D:
			grab_object(body, right_hand_attachment)
			object_in_right_hand = body
			break

func release_left():
	if object_in_left_hand:
		release_object(left_hand_attachment, object_in_left_hand)
		object_in_left_hand = null

func release_right():
	if object_in_right_hand:
		release_object(right_hand_attachment, object_in_right_hand)
		object_in_right_hand = null

func release_object(attachment_point: Marker3D, obj: RigidBody3D) -> void:
	if not obj or not is_instance_valid(obj): return
	if obj.is_in_group("gun"):
		obj.source = null
	var global_pos = obj.global_position
	var scene_root = get_tree().current_scene
	attachment_point.remove_child(obj)
	scene_root.add_child(obj)
	
	# Restauramos la posición exacta
	obj.global_position = global_pos

	obj.collision_layer = 1
	obj.collision_mask = 1

func grab_object(obj: RigidBody3D, hand_attachment: Marker3D) -> void:
	if not obj: return
	
	# Find attachment point if exists
	var obj_attachment = obj.find_child("AttachmentPoint")
	
	# Store original transform
	var original_global_transform = obj.global_transform
	
	# Temporarily disconnect signals
	var grab_area = right_grab_area if hand_attachment == right_hand_attachment else left_grab_area
	var signal_name = "_on_grab_area_r_body_entered" if hand_attachment == right_hand_attachment else "_on_grab_area_l_body_entered"
	
	if grab_area.body_entered.is_connected(get(signal_name)):
		grab_area.body_entered.disconnect(get(signal_name))
	
	# Reparent object
	var original_parent = obj.get_parent()
	original_parent.remove_child(obj)
	hand_attachment.add_child(obj)
	
	if obj_attachment:
		# Calculate offset between object center and attachment point
		var attachment_offset = obj_attachment.global_transform.origin - original_global_transform.origin
		
		# Position object so attachment point matches hand position
		obj.global_position = hand_attachment.global_position - attachment_offset
		
		# For guns, align with hand rotation
		if obj.is_in_group("gun"):
			obj.global_rotation = hand_attachment.global_rotation
			obj.source = self
		else:
			# Align object with hand orientation
			obj.global_transform.basis = hand_attachment.global_transform.basis
	else:
		# No attachment point, use center
		obj.global_transform = hand_attachment.global_transform
	
	# Configure physics
	obj.freeze = true
	obj.collision_layer = 0
	obj.collision_mask = 0
	
	# Reconnect signals after delay
	await get_tree().create_timer(0.1).timeout
	if not grab_area.body_entered.is_connected(get(signal_name)):
		grab_area.body_entered.connect(get(signal_name))

func _on_grab_area_r_body_entered(body: Node3D) -> void:
	if right_grip_pressed and not object_in_right_hand and body.is_in_group("grabbable") and body is RigidBody3D:
		grab_object(body, right_hand_attachment)
		object_in_right_hand = body

func _on_grab_area_l_body_entered(body: Node3D) -> void:
	if left_grip_pressed and not object_in_left_hand and body.is_in_group("grabbable") and body is RigidBody3D:
		grab_object(body, left_hand_attachment)
		object_in_left_hand = body

func onLevelUp():
	stats["XP"].value = 0
	stats["LVL"].value += 1
	stats["XP"].max += 50 * stats["LVL"].value
	print("LVL UP!, current level = ", stats["LVL"].value)
	playLevelUpAnimation()
	levelUp.emit

func jump():
	velocity.y += 200

func playLevelUpAnimation():
	var yippieInstance = yippie.instantiate()
	add_child(yippieInstance)
	
func die():
	get_tree().paused = true


func _on_timer_timeout() -> void:
	stats["HP"].value += 1

func hurtSound():
	audio_stream_player.playing = true
	
