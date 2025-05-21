extends CanvasLayer
@onready var player: baseEntity = null
@onready var lvlUpSound = load("res://assets/sounds/12_3.wav")
@onready var audioPlayer = $AudioStreamPlayer
@onready var hpBar = $HPBar
@onready var xpBar = $XPBar
@onready var label = $Label

func _ready() -> void:
	player = get_tree().current_scene.get_node("player")

func _process(delta: float) -> void:
	updateBars()
	updateLabel()
	

func updateBars():
	xpBar.max_value = player.stats["XP"].max
	xpBar.value = player.stats["XP"].value
	
	hpBar.max_value = player.stats["HP"].max
	hpBar.value = player.stats["HP"].value
	
func updateLabel():
	label.set_text("Current level = " + str(player.stats["LVL"].value))
