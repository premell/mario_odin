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

	update_from_collisions(player.position)
}

update_from_collisions :: proc(position: [2]f32) {
	// atm just take the closest path to getting out...

	for block in world.blocks {


		collision := check_collision(
			player.hit_box,
			player.position,
			block.hit_box,
			block.position,
		)

		// if block.position == {3, 0} {
		// 	fmt.print(collision)
		// }

		if !collision {continue}

		shortest_distance: f32 = 1000.0
		side_with_shortest_distance_to_escape := DIRECTION.UP

		distance_to_escape_top := block.position.y + block.hit_box.height - player.position.y
		distance_to_escape_bottom := player.position.y + player.hit_box.height - block.position.y
		distance_to_escape_left := player.position.x + player.hit_box.width - block.position.x
		distance_to_escape_right := block.position.x + block.hit_box.width - player.position.x

		if distance_to_escape_top < shortest_distance &&
		   distance_to_escape_top > -EPSILON &&
		   distance_to_escape_top < block.hit_box.height {
			shortest_distance = distance_to_escape_top
			side_with_shortest_distance_to_escape = DIRECTION.UP
		}

		if distance_to_escape_bottom < shortest_distance &&
		   distance_to_escape_bottom > -EPSILON &&
		   distance_to_escape_bottom < block.hit_box.height {
			shortest_distance = distance_to_escape_bottom
			side_with_shortest_distance_to_escape = DIRECTION.DOWN
		}


		if distance_to_escape_left < shortest_distance &&
		   distance_to_escape_left > -EPSILON &&
		   distance_to_escape_left < block.hit_box.width {
			shortest_distance = distance_to_escape_left
			side_with_shortest_distance_to_escape = DIRECTION.LEFT
		}

		if distance_to_escape_right < shortest_distance &&
		   distance_to_escape_right > -EPSILON &&
		   distance_to_escape_right < block.hit_box.width {
			shortest_distance = distance_to_escape_right
			side_with_shortest_distance_to_escape = DIRECTION.RIGHT
		}

		if side_with_shortest_distance_to_escape == DIRECTION.UP {
			player.position.y += distance_to_escape_top
			player.vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded
			player.velocity.y = 0
		} else if side_with_shortest_distance_to_escape == DIRECTION.DOWN {
			player.position.y -= distance_to_escape_bottom
		} else if side_with_shortest_distance_to_escape == DIRECTION.LEFT {
			player.position.x -= distance_to_escape_left
		} else if side_with_shortest_distance_to_escape == DIRECTION.RIGHT {
			player.position.x += distance_to_escape_right
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
) -> bool {
	x_1 := position1[0]
	x_2 := position2[0]

	y_1 := position1[1]
	y_2 := position2[1]

	hit_right := x_1 - x_2 > -EPSILON && (x_1 - x_2) < hitbox2.width + EPSILON
	hit_left := x_2 - x_1 > -EPSILON && (x_2 - x_1) < hitbox1.width + EPSILON

	hit_top := y_2 - y_1 > -EPSILON && (y_2 - y_1) < hitbox1.height + EPSILON
	hit_bottom := y_1 - y_2 > -EPSILON && (y_1 - y_2) < hitbox2.height + EPSILON

	hit_horizontally := hit_right || hit_left
	hit_vertically := hit_top || hit_bottom

	if (hit_top || hit_bottom) && (hit_left || hit_right) {
		return true
	} else {
		return false
	}
}
