# Air.gd
extends PlayerState

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	if _msg.has("do_jump"):
		player.velocity.y = player.jump_velocity
		player.animated_sprite.play("Jump")

func physics_update(delta: float) -> void:
	# Horizontal movement.
	player.move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	player.velocity.x = lerp(player.velocity.x, player.move_speed * player.move_direction, player._get_h_weight())

	# Vertical movement.
	# Apply gravity.
	player.velocity.y += player.gravity * delta

	# Change animation direction.
	if player.move_direction != 0:
		player.animated_sprite.scale.x = player.move_direction

	if player.velocity.y > player.gravity:
		player.velocity.y = player.gravity

	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	# Landing.
	if player._ray_check_is_grounded():
		if player.move_direction == 0:
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Walk")
