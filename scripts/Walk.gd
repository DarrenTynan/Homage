# Walk.gd
extends PlayerState

func physics_update(delta: float) -> void:
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.
	if not player._ray_check_is_grounded():
		state_machine.transition_to("Air")
		return

	player.move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	player.velocity.x = lerp(player.velocity.x, player.move_speed * player.move_direction, player._get_h_weight())
	player.velocity.y += player.gravity * delta
	if player.move_direction != 0:
		player.animated_sprite.scale.x = player.move_direction
		player.animated_sprite.play("Walk")

	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", { do_jump = true })
	elif player.move_direction == 0:
		state_machine.transition_to("Idle")
