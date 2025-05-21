extends CanvasLayer

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var HPBar: ProgressBar = $HPBar
@onready var XPBar: ProgressBar = $XPBar
@onready var LVLLabel: Label = $Label

var stats : Dictionary = {
	"HP": Main.stat.new(100, 0, 100),
	"XP": Main.stat.new(0, 0, 100),
	"LVL": Main.stat.new(1, 1, 100)
}

func _ready() -> void:
	if !player:
		push_error("No se encontró el jugador en el grupo 'player'")
		set_process(false)
		return
	
	# Inicialización segura de valores
	stats["HP"] = player.stats["HP"]
	stats["XP"]  = player.stats["XP"]
	stats["LVL"]  = player.stats["LVL"]

func _physics_process(delta: float) -> void:
	if !player:
		return
	
	if stats != player.stats:	
		updateStats()

func updateStats() -> void:
	stats = player.stats
