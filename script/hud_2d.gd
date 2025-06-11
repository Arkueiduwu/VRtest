extends CanvasLayer
@onready var control: Control = $Control

@onready var player: baseEntity = null
@onready var lvlUpSound = load("res://assets/sounds/12_3.wav")
@onready var audioPlayer = $AudioStreamPlayer
@onready var hpBar = $HPBar
@onready var xpBar = $XPBar
@onready var label = $Label
@onready var control_2: Control = $Control2

func _ready() -> void:
	player = get_tree().current_scene.get_node("player")

func _process(delta: float) -> void:
	if Main.ganaste:
		control.visible = true
	if Main.perdiste:
		control_2.visible = true
	updateBars()
	updateLabel()
	

func updateBars():
	xpBar.max_value = player.stats["XP"].max
	xpBar.value = player.stats["XP"].value
	
	hpBar.max_value = player.stats["HP"].max
	hpBar.value = player.stats["HP"].value
	
func updateLabel():
	label.set_text(str(player.stats["LVL"].value))
