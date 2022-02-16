class_name Player
extends KinematicBody2D

# const UP = Vector2(0, -1)
const SLOPE_STOP = 64

# Player velocity
var velocity = Vector2()
# Player speed is 5 * the tile size
var move_speed = 5 * 16
export var gravity = 100
# -1, 0, 1
var move_direction
# Jump height
export var jump_velocity = -80

var player_life = 100
var is_hit = false

onready var raycast_down = $RayCastDown
onready var animated_sprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# var entityNode = get_tree().get_root().find_node("Entity", true, false)
	# entityNode.connect("playerSpotted", self, "handlePlayerSpotted")


# Signal callback.
func handlePlayerSpotted():
	print("handlePlayerSpotted")


func _get_h_weight():
	return 0.2 if _ray_check_is_grounded() else 0.1


# Signal callback
func takeDamage(damage):
	player_life -= damage
	is_hit = true
	$AnimatedSprite.play("GetHit")


func _ray_check_is_grounded():
	return true if raycast_down.is_colliding() else false

func get_position():
	return self.position
