extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 25
const MAXGRAVITY = 50
const MAXSPEED = 50
const WEAPONDAMAGE = 5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var movement = Vector2()
var moving_right = true
var player_in_range = false
var is_attacking = false

onready var AnimatedSprite: = $AnimatedSprite
onready var HitBox: = $Area2D/HitBox

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	check_raycasts()
	attack()
	animate()
	move_entity()

func attack():
	if player_in_range && AnimatedSprite.animation != "Attack":
		AnimatedSprite.play("Attack")
		is_attacking = true
	if player_in_range && !AnimatedSprite.playing:
		is_attacking = false

	
# Check raycasts:
#	check down for on floor
#	check forward for player
func check_raycasts():
	if(!$RayCastDown.is_colliding() || $RayCastForward.is_colliding()):
		var collider = $RayCastForward.get_collider()

		if collider && collider.name == "Player":
			movement = Vector2.ZERO
			player_in_range = true
		else:
			moving_right = !moving_right
			scale.x =- scale.x

# Apply gravity until max gravity. If on floor then stop movement
# If player in range then stop moving and apply attack.
func move_entity():
	movement.y += GRAVITY

	if(movement.y > MAXGRAVITY):
		movement.y = MAXGRAVITY

	if(is_on_floor()):
		movement.y = 0

	if !player_in_range:
		movement.x = MAXSPEED if moving_right else -MAXSPEED
		
	movement = move_and_slide(movement, UP)

# Play walk animation if entity moving else play idle.
func animate():
	if is_attacking: return
	if movement != Vector2.ZERO:
		$AnimatedSprite.play("Walk")
	else:
		$AnimatedSprite.play("Idle")


func _on_AnimatedSprite_frame_changed():
	if AnimatedSprite.animation == "Attack" && AnimatedSprite.frame >= 7 && AnimatedSprite.frame <= 8:
		HitBox.disabled = false
		# print("hitbox activated")
	else:
		HitBox.disabled = true
		# print("hitbox deactivated")


func _on_Area2D_body_entered(body:Node):
	if body.has_method("takeDamage"):
		body.takeDamage(WEAPONDAMAGE)
