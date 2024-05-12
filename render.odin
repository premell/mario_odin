package main
import "core:fmt"
import SDL "vendor:sdl2"

render_world :: proc() {
	camera_bottom_left_corner :=
		player.position +
		[2]f32{f32(player.hit_box.width), f32(player.hit_box.height + 5)} / 2 -
		[2]f32{CAMERA_WIDTH, CAMERA_HEIGHT} / 2


	// RENDER BLOCKS
	for block, index in world.blocks {
		switch block.type {
		case BLOCK.fire:
			SDL.SetRenderDrawColor(game.renderer, 255, 0, 0, 255)
		case BLOCK.wall:
			SDL.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)
		case BLOCK.ground:
			SDL.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)
		case BLOCK.platform:
			SDL.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)
		case BLOCK.questionmark_block:
			SDL.SetRenderDrawColor(game.renderer, 255, 150, 0, 255)
		case BLOCK.door:
			SDL.SetRenderDrawColor(game.renderer, 155, 155, 155, 255)
		}

		block_position_relative_to_camera := block.position - camera_bottom_left_corner

		SDL.RenderFillRect(
			game.renderer,
			&SDL.Rect {
				i32(block_position_relative_to_camera[0] * PIXELS_PER_M),
				WINDOW_HEIGHT - i32(
					(block_position_relative_to_camera[1] + f32(block.hit_box.height)) *
					PIXELS_PER_M, // flip so x = 0 on bottom
				),
				i32(block.hit_box.width * PIXELS_PER_M),
				i32(block.hit_box.height * PIXELS_PER_M),
			},
		)
	}
	// RENDER CREATURES
	for creature, index in world.creatures {
		#partial switch creature.type {
		case CREATURE_TYPE.goomba:
			SDL.SetRenderDrawColor(game.renderer, 0, 255, 0, 255)
		}

		creature_position_relative_to_camera := creature.position - camera_bottom_left_corner

		SDL.RenderFillRect(
			game.renderer,
			&SDL.Rect {
				i32(creature_position_relative_to_camera[0] * PIXELS_PER_M),
				WINDOW_HEIGHT - i32(
					(creature_position_relative_to_camera[1] + f32(creature.hit_box.height)) *
					PIXELS_PER_M, // flip so x = 0 on bottom
				),
				i32(creature.hit_box.width * PIXELS_PER_M),
				i32(creature.hit_box.height * PIXELS_PER_M),
			},
		)
	}


	// RENDER PLAYER
	player_position_relative_to_camera := player.position - camera_bottom_left_corner

	if includes(player.upgrades, UPGRADE.fireball_man) {
		SDL.SetRenderDrawColor(game.renderer, 255, 0, 0, 255)
	} else if includes(player.upgrades, UPGRADE.salmonsays) {
		SDL.SetRenderDrawColor(game.renderer, 0, 0, 255, 255)
	} else if includes(player.upgrades, UPGRADE.superman) {
		SDL.SetRenderDrawColor(game.renderer, 180, 180, 180, 255)
	} else {
		SDL.SetRenderDrawColor(game.renderer, 70, 70, 70, 255)
	}


	SDL.RenderFillRect(
		game.renderer,
		&SDL.Rect{i32(player_position_relative_to_camera[0] * PIXELS_PER_M), WINDOW_HEIGHT - i32(
				(player_position_relative_to_camera[1] + f32(player.hit_box.height)) *
				PIXELS_PER_M, // flip so x = 0 on bottom
			), i32(player.hit_box.width * PIXELS_PER_M), i32(player.hit_box.height * PIXELS_PER_M)},
	)

	SDL.RenderPresent(game.renderer)

	SDL.SetRenderDrawColor(game.renderer, 255, 255, 255, 100)
	SDL.RenderClear(game.renderer)
}
