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


update_world :: proc(ms_since_last_update: f32){
  left := includes(keyboard.pressed_or_held_last_frame, Action.LEFT)
  right := includes(keyboard.pressed_or_held_last_frame, Action.RIGHT)
  jump := includes(keyboard.pressed_or_held_last_frame, Action.JUMP)
  
  if left{
    player.acceleration.x = -PLAYER_ACCELERATION
  }else if right{
    player.acceleration.x = PLAYER_ACCELERATION
  }

  if player.vertical_movement_state == VERTICAL_MOVEMENT_STATE.grounded && jump{
    player.velocity.y = 100
  }

  player.velocity += player.acceleration * ms_since_last_update/1000.0
  player.position += player.velocity * ms_since_last_update/1000.0


   //update_entity_positions()
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
