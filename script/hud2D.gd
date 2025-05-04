extends CanvasLayer

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var HPBar: ProgressBar = $HPBar
@onready var XPBar: ProgressBar = $XPBar
@onready var LVLLabel: Label = $Label

var currentHP: float = 0.0
var maxHP: float = 0.0
var currentXP: float = 0.0
var maxXP: float = 0.0
var LVL: int = 0

func _ready() -> void:
	if !player:
		push_error("No se encontró el jugador en el grupo 'player'")
		set_process(false)
		return
	
	# Inicialización segura de valores
	currentHP = player.HP
	maxHP = player.maxHP
	currentXP = player.XP
	maxXP = player.maxXP
	LVL = player.LVL
	
	# Actualización inicial del HUD
	update_hud()

func _physics_process(delta: float) -> void:
	if !player:
		return
	
	# Actualización condicional (solo si cambian los valores)
	if currentHP != player.HP || maxHP != player.maxHP:
		currentHP = player.HP
		maxHP = player.maxHP
		update_health()
	
	if currentXP != player.XP || maxXP != player.maxXP:
		currentXP = player.XP
		maxXP = player.maxXP
		update_xp()
	
	if LVL != player.LVL:
		LVL = player.LVL
		update_level()

func update_hud() -> void:
	update_health()
	update_xp()
	update_level()

func update_health() -> void:
	if HPBar:
		HPBar.max_value = maxHP
		HPBar.value = currentHP

func update_xp() -> void:
	if XPBar:
		XPBar.max_value = maxXP
		XPBar.value = currentXP

func update_level() -> void:
	if LVLLabel:
		LVLLabel.text = "LVL: %d" % LVL
