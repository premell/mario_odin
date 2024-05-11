package main

import "core:fmt"
import "core:math"
import "core:time"

update_world :: proc(ms_since_last_update: f32) {
	left := includes(keyboard.pressed_or_held_last_frame, Action.LEFT)
	right := includes(keyboard.pressed_or_held_last_frame, Action.RIGHT)
	jump := includes(keyboard.pressed_or_held_last_frame, Action.JUMP)
	grounded := player.vertical_movement_state == VERTICAL_MOVEMENT_STATE.grounded

	friction_applied := false
	if left {
		player.acceleration.x = -PLAYER_ACCELERATION
	} else if right {
		player.acceleration.x = PLAYER_ACCELERATION
	} else if math.abs(player.acceleration.x) > 0 {
		player.acceleration.x = -FRICTION * math.sign(player.velocity.x)
		friction_applied = true
	}

	if grounded && jump {
		player.velocity.y = 25
		player.vertical_movement_state = VERTICAL_MOVEMENT_STATE.jumping
	}

	velocity_before := player.velocity
	velocity_after := player.velocity.x + player.acceleration.x * ms_since_last_update / 1000.0

	player.velocity.x =
		math.sign(velocity_after) * math.min(math.abs(velocity_after), PLAYER_MAX_RUN_VELOCITY)

	if !grounded {player.velocity.y += GRAVITY * ms_since_last_update / 1000.0}

	changed_direction_from_friction :=
		friction_applied && math.sign(velocity_before.x) != math.sign(player.velocity.x)

	if changed_direction_from_friction {
		player.acceleration.x = 0
		player.velocity.x = 0
	}

	player.velocity.y += GRAVITY * ms_since_last_update / 1000.0


	player.position = player.position + player.velocity * ms_since_last_update / 1000.0

	update_collisions(player.position)
}


update_collisions :: proc(position: [2]f32) {
	// atm just take the closest path to getting out...

	// check creatures
	for creature in world.creatures {
		collision := check_collision(
			player.hit_box,
			player.position,
			creature.hit_box,
			creature.position,
		)

		if collision.direction == DIRECTION.NONE {continue}

		if collision.direction == DIRECTION.DOWN {
			world.creatures = {}
		} else {
			player.position.x = -10000
		}
	}


	// check blocks
	for block in world.blocks {
		collision := check_collision(
			player.hit_box,
			player.position,
			block.hit_box,
			block.position,
		)

		if collision.direction == DIRECTION.NONE {continue}

		if collision.direction == DIRECTION.UP {
			player.position.y = collision.position_to_escape
		} else if collision.direction == DIRECTION.DOWN {
			player.position.y = collision.position_to_escape
			player.vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded
			player.velocity.y = 0
		} else if collision.direction == DIRECTION.LEFT {
			player.position.x = collision.position_to_escape
		} else if collision.direction == DIRECTION.RIGHT {
			player.position.x = collision.position_to_escape
		}
	}
}

// collision direction is from the perspective of hitbox1. so if the collision is right
// position2 is to the right of position1
check_collision :: proc(
	hitbox1: HitBox,
	position1: [2]f32,
	hitbox2: HitBox,
	position2: [2]f32,
) -> Collision {
	x_1 := position1[0]
	x_2 := position2[0]

	y_1 := position1[1]
	y_2 := position2[1]

	top_hit_distance: f32 = hitbox1.height - abs(y_1 - y_2)
	top_was_hit :=
		y_2 - y_1 > -EPSILON &&
		top_hit_distance > -EPSILON &&
		top_hit_distance < hitbox1.height + EPSILON

	bottom_hit_distance: f32 = hitbox2.height - abs(y_2 - y_1)
	bottom_was_hit :=
		y_1 - y_2 > -EPSILON &&
		bottom_hit_distance > -EPSILON &&
		bottom_hit_distance < hitbox2.height + EPSILON

	left_hit_distance: f32 = hitbox2.width - abs(x_2 - x_1)
	left_was_hit :=
		x_1 - x_2 > -EPSILON &&
		left_hit_distance > -EPSILON &&
		left_hit_distance < hitbox2.width + EPSILON

	right_hit_distance: f32 = hitbox1.width - abs(x_1 - x_2)
	right_was_hit :=
		x_2 - x_1 > -EPSILON &&
		right_hit_distance > -EPSILON &&
		right_hit_distance < hitbox1.width + EPSILON

	if !(top_was_hit || bottom_was_hit) ||
	   !(left_was_hit || right_was_hit) {return Collision{direction = DIRECTION.NONE}}

	shortest_distance: f32 = 10000.0
	position_to_escape: f32 = 0.0
	shortest_direction := DIRECTION.NONE

	if top_was_hit && top_hit_distance < shortest_distance {
		shortest_distance = top_hit_distance

		shortest_direction = DIRECTION.UP
		position_to_escape = y_2 - hitbox1.height
	}
	if bottom_was_hit && bottom_hit_distance < shortest_distance {
		shortest_distance = bottom_hit_distance

		shortest_direction = DIRECTION.DOWN
		position_to_escape = y_2 + hitbox2.height
	}
	if left_was_hit && left_hit_distance < shortest_distance {
		shortest_distance = left_hit_distance

		shortest_direction = DIRECTION.LEFT
		position_to_escape = x_2 + hitbox2.width
	}
	if right_was_hit && right_hit_distance < shortest_distance {
		shortest_distance = right_hit_distance

		shortest_direction = DIRECTION.RIGHT
		position_to_escape = x_2 - hitbox1.width
	}

	return Collision{direction = shortest_direction, position_to_escape = position_to_escape}
}
