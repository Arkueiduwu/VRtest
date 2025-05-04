extends Node3D

@onready var HUD2DScene: PackedScene = load("res://scenes/HUD2D.tscn")
@onready var quad: MeshInstance3D = $quad
@onready var subViewport: SubViewport = $SubViewport

func _ready():
	# Configurar Viewport primero
	subViewport.size = Vector2i(1920, 1080)
	subViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	subViewport.transparent_bg = true
	
	# Añadir HUD
	var HUD2DInstance = HUD2DScene.instantiate()
	subViewport.add_child(HUD2DInstance)
	
	# Configurar material después de 2 frames (más seguro)
	await get_tree().create_timer(0.1).timeout
	
	var material = StandardMaterial3D.new()
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = subViewport.get_texture()
	material.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.alpha_scissor_threshold = 0.1
	material.no_depth_test = true
	
	quad.mesh = QuadMesh.new()
	quad.mesh.size = Vector2(2, 1)
	quad.material_override = material
