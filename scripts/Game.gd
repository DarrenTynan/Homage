extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate the canvas layer for debug
	var overlay = load("res://scenes/DebugOverlay.tscn").instance()

	# Append text to canvas layer.
	overlay.add_stats(("Player Position (x,y)"), $Player, "get_position", true)
	overlay.add_stats(("Player Life"), $Player, "player_life", false)

	overlay.add_stats(("Player Velocity"), $Player, "velocity", false)
	overlay.add_stats(("Player Move Speed"), $Player, "move_speed", false)
	overlay.add_stats(("Player Gravity"), $Player, "gravity", false)
	overlay.add_stats(("Player Move Direction"), $Player, "move_direction", false)
	
	overlay.add_stats(("Player Current State"), $Player/StateMachine, "state", false)
	overlay.add_stats(("Player Is RayCast Grounded"), $Player, "_ray_check_is_grounded", true)
	add_child(overlay)
