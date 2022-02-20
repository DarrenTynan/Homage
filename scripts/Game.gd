extends Node2D

onready var camera_controller: Camera2D = $Camera
onready var map_controller: Node2D = $Level_01
onready var current_room = map_controller.START_ROOM

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate the canvas layer for debug
	var overlay = load("res://scenes/DebugOverlay.tscn").instance()

	# Append text to canvas layer.
	overlay.add_stats(("Block Exits"), camera_controller, "block_exits", false)

	overlay.add_stats(("Current Room"), self, "current_room", false)
	overlay.add_stats(("Map Width Screens"), $Level_01, "MAP_WIDTH_SCREENS", false)
	overlay.add_stats(("Cell Size Pixels"), $Level_01, "CELL_SIZE", false)
	overlay.add_stats(("Map Screen in Rooms"), $Level_01, "MAP_SCREEN_SIZE_CELLS", false)
	overlay.add_stats(("Map Screen in Pixels"), $Level_01, "MAP_SCREEN_SIZE_PIXELS", false)

	overlay.add_stats(("Player Position (x,y)"), $Player, "get_position", true)
	overlay.add_stats(("Player Life"), $Player, "player_life", false)
	overlay.add_stats(("Player Velocity"), $Player, "velocity", false)
	overlay.add_stats(("Player Move Speed"), $Player, "move_speed", false)
	overlay.add_stats(("Player Gravity"), $Player, "gravity", false)
	overlay.add_stats(("Player Move Direction"), $Player, "move_direction", false)
	
	overlay.add_stats(("Player Current State"), $Player/StateMachine, "state", false)
	overlay.add_stats(("Player Is RayCast Grounded"), $Player, "_ray_check_is_grounded", true)
	add_child(overlay)

	# Change the room to the start room
	_change_room()

# UI keys are for screen flip debug.
func _input(event: InputEvent) -> void:
	var direction = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		direction = Vector2.UP

	if Input.is_action_just_pressed("ui_down"):
		direction = Vector2.DOWN

	if Input.is_action_just_pressed("ui_left"):
		direction = Vector2.LEFT

	if Input.is_action_just_pressed("ui_right"):
		direction = Vector2.RIGHT

	# camera_controller.set_position(pos)
	_manage_direction(direction)


func _manage_direction(direction:Vector2) -> void:
	# Get the new room, the methods will handle invalid values just fine.
	var newroom = map_controller.get_valid_room_in_direction_from_room(current_room, direction)
	if newroom == -1:
		return
		
	# We have a new room, simply set it and mark input as handled. 
	current_room = newroom
	get_tree().set_input_as_handled()

	# Ask the camera nicely to change room
	_change_room()


func _change_room():
	# Take the current room and set the camera to this.
	var newpos = map_controller.get_room_topleft_global(current_room)
	
	# Invalid room, so just return.
	if newpos == map_controller.INVALID_ROOM:
		return
		
	camera_controller.set_position(newpos)

	# Refresh the exit blocks.
	var exits = map_controller.get_all_exits_for_room(current_room)
	camera_controller.set_exits(exits[0] >= 0, exits[1] >= 0, exits[2] >= 0, exits[3] >= 0)


func _on_Camera_room_change(change_direction):
	if typeof(change_direction) != TYPE_VECTOR2:
		return

	# print("_on_camera_room_change: change direction ", change_direction)
	# return
	_manage_direction(change_direction)
