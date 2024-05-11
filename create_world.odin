package main

import "core:fmt"

create_world :: proc() {
	player = Player {
		hit_box                 = {1, 1},
		vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded,
	}

	world = World {
		blocks    = {
			{type = BLOCK.ground, position = {-20, -20}, hit_box = {height = 20, width = 1000}},
			{type = BLOCK.ground, position = {5, 5}, hit_box = {height = 1, width = 1}},
			{type = BLOCK.ground, position = {-3, 0}, hit_box = {height = 1, width = 1}},
			{type = BLOCK.ground, position = {3, 0}, hit_box = {height = 1, width = 1}},
		},
		creatures = {
			{
				type = CREATURE_TYPE.goomba,
				hit_box = {1, 1},
				vertical_movement_state = VERTICAL_MOVEMENT_STATE.grounded,
				has_jumped = false,
				facing_left_else_right = false,
				health = 100,
				position = {2, 0},
			},
		},
	}
}
