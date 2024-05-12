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
		},
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

	add_platform(
		{type = BLOCK.platform, position = {0, 8}, hit_box = {height = 1, width = 5}},
		&{range = {-4, 1}, velocity = 5, moving_right_else_left = true},
	)


}

add_platform :: proc(block: Block, platform: ^Platform) {
	append(&world.blocks, block)
	platform.block = &world.blocks[len(world.blocks) - 1]
	append(&world.platforms, platform^)
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
