package main

import "core:fmt"
import "core:math"
import "core:time"

update_world :: proc(ms_since_last_update: f32) {
	move_platforms(ms_since_last_update)
	move_bouncing_blocks(ms_since_last_update)
	move_creatures(ms_since_last_update)
	move_player(ms_since_last_update)

	for creature in &world.creatures {
		update_collisions_blocks(&creature)
	}
	update_collisions_blocks(&player)

	update_player_creature_collision()
}

move_platforms :: proc(ms_since_last_update: f32) {
	for platform in &world.platforms {
		platform.block.position.x +=
			(platform.moving_right_else_left ? 1 : -1) *
			platform.velocity *
			ms_since_last_update /
			1000.0

		if platform.block.position.x < platform.range[0] {
			platform.block.position.x = platform.range[0]
			platform.moving_right_else_left = true
		} else if platform.range[1] < platform.block.position.x {
			platform.block.position.x = platform.range[1]
			platform.moving_right_else_left = false
		}
	}
}

move_bouncing_blocks :: proc(ms_since_last_update: f32) {
	for block, index in &world.bouncing_blocks {
		block.velocity.y += GRAVITY * ms_since_last_update / 1000.0
		block.block.position.y += block.velocity.y * ms_since_last_update / 1000.0

		if block.block.position.y < block.original_position.y {
			block.block.position.y = block.original_position.y
			block.velocity.y = 0
			unordered_remove(&world.bouncing_blocks, index)
		}
	}
}

move_player :: proc(ms_since_last_update: f32) {
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

}

move_creatures :: proc(ms_since_last_update: f32) {
	for creature in &world.creatures {
		#partial switch creature.type {
		case CREATURE_TYPE.goomba:
			if creature.vertical_movement_state == VERTICAL_MOVEMENT_STATE.grounded {
				GOOMBA_MOVEMENT_SPEED :: 4
				creature.position.x +=
					(creature.facing_right_else_left ? 1 : -1) *
					GOOMBA_MOVEMENT_SPEED *
					ms_since_last_update /
					1000.0
			}

			creature.velocity.y += GRAVITY * ms_since_last_update / 1000.0
			creature.position.y += creature.velocity.y * ms_since_last_update / 1000.0

		}
	}
}


update_player_creature_collision :: proc() {
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
}

update_collisions_blocks :: proc(obj: ^Moveable) {
	obj.vertical_movement_state = VERTICAL_MOVEMENT_STATE.falling

	for block, index in world.blocks {
		collision := check_collision(obj.hit_box, obj.position, block.hit_box, block.position)

		if collision.direction == DIRECTION.NONE {continue}

		if collision.direction == DIRECTION.UP {
			obj.position.y = collision.position_to_escape

			if BLOCK_TYPES[block.type].breakable {
				if includes(player.upgrades, UPGRADE.big_boy) {
					unordered_remove(&world.blocks, index)
				}
			}

			if block.type == BLOCK.questionmark_block {
				add_upgrade(UPGRADE.big_boy)
			} else if BLOCK_TYPES[block.type].bouncable {
				bounce_block(&world.blocks[index])
			}

			// bounce off
			obj.velocity.y = BOUNCE_OF_TOP_SPEED
		} else if collision.direction == DIRECTION.DOWN {
			obj.position.y = collision.position_to_escape
			obj.vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded
			obj.velocity.y = 0
		} else if collision.direction == DIRECTION.LEFT {
			obj.position.x = collision.position_to_escape

			#partial switch obj.creature_type {
			case CREATURE_TYPE.goomba:
				obj.facing_right_else_left = true
			}
		} else if collision.direction == DIRECTION.RIGHT {
			obj.position.x = collision.position_to_escape

			#partial switch obj.creature_type {
			case CREATURE_TYPE.goomba:
				obj.facing_right_else_left = false
			}
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

bounce_block :: proc(block: ^Block) {
	append(
		&world.bouncing_blocks,
		BouncingBlock{block = block, velocity = {0, 5}, original_position = block.position},
	)
}

add_upgrade :: proc(upgrade: UPGRADE) {
	append(&player.upgrades, upgrade)

	#partial switch upgrade {
	case UPGRADE.big_boy:
		player.hit_box.height = 2
	}

}

remove_upgrade :: proc(upgrade: UPGRADE) {
	remove(&player.upgrades, upgrade)

	#partial switch upgrade {
	case UPGRADE.big_boy:
		player.hit_box.height = 1
	}
}
