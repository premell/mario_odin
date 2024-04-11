package main

import "core:fmt"
import "core:math"

// TODO
// 1) move all creatures and player
// 2) check for collisions
// 3) update grounded_state based on where they moved. if they are inside a wall, push them back etc


// NOTE player action

// should i even use friction and acceleration? jump should use acceleration curve atleast... Make that later!
// yes i do that for now. can fix later


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

	player.position += player.velocity * ms_since_last_update / 1000.0

	update_from_collisions()
}

update_from_collisions :: proc() {
	player.vertical_movement_state = VERTICAL_MOVEMENT_STATE.falling

	for block in world.blocks {
		collisions := check_collision(
			player.hit_box,
			player.position,
			block.hit_box,
			block.position,
		)


		for c in collisions {
			if c.direction == DIRECTION.DOWN {
				player.position.y += c.depth
				player.velocity.y = 0
				player.acceleration.y = 0
				player.vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded
			}
		}
	}
}


check_collision :: proc(
	hitbox1: HitBox,
	position1: [2]f32,
	hitbox2: HitBox,
	position2: [2]f32,
) -> [dynamic]Collision {
	x_1 := position1[0]
	x_2 := position2[0]

	y_1 := position1[1]
	y_2 := position2[1]

	collisions: [dynamic]Collision = {}

	// block is to the right of the player
	hit_right := x_1 > x_2 && (x_1 - x_2) < hitbox2.width
	// block is to the left of the player
	hit_left := x_2 > x_1 && (x_2 - x_1) < hitbox1.width

	// block is above the player
	hit_top := y_2 > y_1 && (y_2 - y_1) < hitbox1.height
	// block is below the player
	hit_bottom := y_1 > y_2 && (y_1 - y_2) < hitbox2.height

	hit_horizontally := hit_right || hit_left
	hit_vertically := hit_top || hit_bottom

	if hit_top || hit_bottom {
		if hit_right {
			append_elem(
				&collisions,
				Collision{direction = DIRECTION.RIGHT, depth = hitbox2.width - (x_2 - x_1)},
			)
		} else if hit_left {
			append_elem(
				&collisions,
				Collision{direction = DIRECTION.LEFT, depth = hitbox1.width - (x_1 - x_2)},
			)
		}
	}

	if hit_left || hit_right {
		if hit_top {
			append_elem(
				&collisions,
				Collision{direction = DIRECTION.UP, depth = hitbox1.height - (y_2 - y_1)},
			)
		} else if hit_bottom {
			append_elem(
				&collisions,
				Collision{direction = DIRECTION.DOWN, depth = hitbox2.height - (y_1 - y_2)},
			)
		}
	}

	return collisions
}


// first := true
//
// update_world :: proc(ms_since_last_update: f32) {
//   apply_stopping_force := true
// 	if (keyboard_state.left.pressed_since_last_update || keyboard_state.left.currently_pressed) {
// 		player.acceleration[0] = -PLAYER_ACCELERATION
//     apply_stopping_force = false
// 	}
//
//   if (keyboard_state.right.pressed_since_last_update ||
// 		   keyboard_state.right.currently_pressed) {
// 		player.acceleration[0] = PLAYER_ACCELERATION
//     apply_stopping_force = false
// 	}
//
//   // TODO and is touching ground
//   if (apply_stopping_force && player.acceleration[0] != 0){
//       player.acceleration[0] = -math.sign(player.velocity[0])*FRICTION
//   }
//
// 	if (keyboard_state.jump.pressed_since_last_update || keyboard_state.jump.currently_pressed) &&
// 	   player.vertical_movement_state == VERTICAL_MOVEMENT_STATE.grounded {
// 		  player.velocity[1] = -10
// 		  player.vertical_movement_state = 
// 	}
//
// 	if (keyboard_state.crouch.pressed_since_last_update ||
// 		   keyboard_state.crouch.currently_pressed) &&
// 	   player.is_grounded {
// 		player.is_crouching = true
// 	}
//
//   velocity_x_before := player.velocity[0]
//   velocity_x_after := player.velocity[0] + player.acceleration[0] * ms_since_last_update / 1000
//
// 	player.velocity[0] = math.sign(velocity_x_after)*math.min(
// 		PLAYER_MAX_RUN_VELOCITY,
// 		math.abs(velocity_x_after)
// 	)
//
//   changed_direction := math.sign(velocity_x_before) !=  math.sign(player.velocity[0])
//   if changed_direction && apply_stopping_force {
//     player.velocity[0] = 0
//     player.acceleration[0] = 0
//   }
//
// 	player.velocity[1] = math.max(
// 		PLAYER_MAX_FALL_VELOCITY,
// 		player.velocity[1] + GRAVITY * ms_since_last_update / 1000,
// 	)
//
//   player.velocity[1] = 0
//
//   //fmt.println(player.position)
// 	player.position += player.velocity * ms_since_last_update / 1000
//
// 	keyboard_state.left.pressed_since_last_update = false
// 	keyboard_state.right.pressed_since_last_update = false
// 	keyboard_state.jump.pressed_since_last_update = false
// 	keyboard_state.crouch.pressed_since_last_update = false
//   
//   update_entity_positions()
// }
//
// update_entity_positions :: proc(){
//   entities :[]int= {1, 2, 3, 4}
//   blocks :[]int= {1, 2, 3, 4}
//
//   for entity in entities {
//     for block in blocks {
//
//       collision, _ := get_collision_direction(entity, block)
//
//      #partial switch collision {
//       case .LEFT, .RIGHT: 
//       case .UP: 
//       case .DOWN: 
//     }
//
//
//     }
//   }
// }
//
// get_collision_direction :: proc(a, b: int) -> (DIRECTION, f32) {
//  return DIRECTION.LEFT, 0.1
// }
//
// get_collision:: proc(a, b: int) -> bool {
//   return true
// }
