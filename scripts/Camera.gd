extends Camera2D


signal room_change(direction)

# Declare member variables here. Examples:
# Setting true means blocked!
var block_exits = true
onready var blockers = [$RoomBlocker/CollisionTop, $RoomBlocker/CollisionBottom, $RoomBlocker/CollisionLeft, $RoomBlocker/CollisionRight]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Lock exits seperatly (up, down, left, right)
	# set_exits(true, true, false, true)
	# Lock exits on current room.
	# lock_room(block_exits)
	pass # Replace with function body.


func set_position(location: Vector2, zoom: float = 1.0) -> void:
	position = location
	if zoom != 1.0:
		self.zoom = Vector2(zoom, zoom)


func lock_room(is_locked: = true):
	block_exits = is_locked
	set_exits(!block_exits, !block_exits, !block_exits, !block_exits)


func set_exits(block_up:bool, block_down:bool, block_left:bool, block_right:bool):
	blockers[0].set_deferred("disabled", block_up)
	blockers[1].set_deferred("disabled", block_down)
	blockers[2].set_deferred("disabled", block_left)
	blockers[3].set_deferred("disabled", block_right)
	# print("Setting exits as follows (u,d,l,r) %s,%s,%s,%s" % [block_up, block_down, block_left, block_right])


func _on_RoomNavigation_body_shape_entered(body_rid:RID, body:Node, body_shape_index:int, local_shape_index:int):

	if local_shape_index < 0 || local_shape_index > 3:
		return

	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var change_direction = directions[local_shape_index]
	emit_signal("room_change", change_direction)
	# print("Camera changing direction room to direction %s as vector %s" % [local_shape_index, change_direction])
