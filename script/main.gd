extends Node
var player : baseEntity = null

class stat:
	var value: int
	var min: int
	var max: int
	
	func _init(v: int = 0, mn: int = 0, mx: int = 100) -> void:
		value = v
		min = mn
		max = mx

func changeStat(target: Node3D, type: String, amount: int) -> void:
	target.stats[type].value = clamp(target.stats[type].value + amount, target.stats[type].min, target.stats[type].max)
	if type == "HP" and target.stats[type].value == target.stats[type].min:
		if target.has_method("die"):
			target.die()
		else:
			push_warning("Target %s has 0 HP but no die() method" % target.name)
