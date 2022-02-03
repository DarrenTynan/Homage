extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 50
const MAXSPEED = 50
const MAXGRAVITY = 100
const JUMPSPEED = 500

const SLOPE_STOP = 64

# Player velocity
var velocity = Vector2()
# Player speed is 5 * the tile size
var move_speed = 5 * 16
export var gravity = 100
var move_direction
# Jump height
export var jump_velocity = -80
var is_grounded : bool

var movement = Vector2()
var player_life = 100
var is_hit = false

onready var raycast_down = $RayCastDown

# Called when the node enters the scene tree for the first time.
func _ready():
	var entityNode = get_tree().get_root().find_node("Entity", true, false)
	entityNode.connect("playerSpotted", self, "handlePlayerSpotted")


# Signal callback.
func handlePlayerSpotted():
	print("handlePlayerSpotted")


func _get_input():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction != 0:
		$AnimatedSprite.scale.x = move_direction


func _input(event):
	if event.is_action_pressed("jump") && is_grounded:
		velocity.y = jump_velocity


func _get_h_weight():
	return 0.2 if is_grounded else 0.1


func _physics_process(delta):
	# Get the keyboard input and adjust.
	_get_input()
	# Apply gravity
	velocity.y += gravity * delta
	is_grounded = is_on_floor()

	velocity = move_and_slide(velocity, UP, SLOPE_STOP)

	# if Input.is_action_pressed("left"):
	# 	movement.x =- MAXSPEED
	# 	$AnimatedSprite.play("WalkRight")
	# 	$AnimatedSprite.set_flip_h(true)
	# elif Input.is_action_pressed("right"):
	# 	movement.x = MAXSPEED
	# 	$AnimatedSprite.play("WalkRight")
	# 	$AnimatedSprite.set_flip_h(false)
	# else:
	# 	movement.x = 0
	# 	$AnimatedSprite.play("Idle")

	# if is_hit:
	# 	$AnimatedSprite.play("GetHit")

	# if is_on_floor():
	# 	if Input.is_action_just_pressed('jump'):
	# 		movement.y =- JUMPSPEED

	# movement.y += GRAVITY

	# if movement.y > MAXGRAVITY:
	# 	movement.y = MAXGRAVITY
	
	# movement = move_and_slide(movement, UP)


# Signal callback
func takeDamage(damage):
	player_life -= damage
	is_hit = true
	$AnimatedSprite.play("GetHit")


func _check_is_grounded():
	return true if raycast_down.is_colliding() else false

