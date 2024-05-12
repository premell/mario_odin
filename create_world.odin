package main

import "core:fmt"
import "core:mem"
import "core:os"

create_world :: proc() {
	player = Player {
		creature_type           = CREATURE_TYPE.player,
		hit_box                 = {1, 1},
		position                = {-4, 0},
		vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded,
	}

	moving_platform_1 := Block {
		type = BLOCK.platform,
		position = {0, 8},
		hit_box = {height = 1, width = 5},
	}

	world = World {
		blocks    = {
			{type = BLOCK.ground, position = {-20, -20}, hit_box = {height = 20, width = 1000}},
			{
				type = BLOCK.questionmark_block,
				position = {5, 5},
				hit_box = {height = 1, width = 1},
			},
			{type = BLOCK.ground, position = {-3, 0}, hit_box = {height = 1, width = 1}},
			{type = BLOCK.ground, position = {-3, 5}, hit_box = {height = 1, width = 1}},
			{type = BLOCK.ground, position = {-2, 5}, hit_box = {height = 1, width = 1}},
			{type = BLOCK.ground, position = {3, 0}, hit_box = {height = 1, width = 1}},
			{type = BLOCK.ground, position = {6, 0}, hit_box = {height = 10, width = 10}},
			moving_platform_1,
		},
		platforms = {{block = &moving_platform_1}},
		creatures = {
			{
				creature_type = CREATURE_TYPE.goomba,
				hit_box = {1, 1},
				vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded,
				has_jumped = false,
				facing_right_else_left = false,
				health = 100,
				position = {2, 0},
			},
		},
	}
}

spawn_goomba :: proc() {
	append(
		&world.creatures,
		Creature {
			creature_type = CREATURE_TYPE.goomba,
			hit_box = {1, 1},
			vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded,
			has_jumped = false,
			facing_right_else_left = false,
			health = 100,
			position = {player.position.x + 5, player.position.y},
		},
	)
}
