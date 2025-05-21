extends CharacterBody3D

class_name baseEntity

var stats : Dictionary = {
	"HP": Main.stat.new(100, 0, 1000),
	"XP": Main.stat.new(0, 0, 100),
	"LVL": Main.stat.new(1, 1, 1000),
	"SPD": Main.stat.new(100, 0, 1000),
	"GLD": Main.stat.new(0, 0, 10000)
}
