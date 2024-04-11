package main

import "core:fmt"
import "core:math"
import glm "core:math/linalg/glsl"
import "core:os"
import "core:strings"
import "core:time"

import "core:image/png"

import gl "vendor:OpenGL"
import SDL "vendor:sdl2"

import SDL_image "vendor:sdl2/image"

main :: proc() {

  //context.logger = log.create_console_logger()

  // tracking_allocator: mem.tracking_allocator
  // mem.tracking_allocator_init(&tracking_allocator, context.allocator)
  // context.allocator = mem.tracking_allocator(&tracking_allocator)



	assert(SDL.Init(SDL.INIT_VIDEO) == 0, SDL.GetErrorString())

	window := SDL.CreateWindow(
		"Odin SDL2 Demo",
		SDL.WINDOWPOS_UNDEFINED,
		SDL.WINDOWPOS_UNDEFINED,
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		{.OPENGL},
	)

	assert(window != nil, SDL.GetErrorString())

	game.renderer = SDL.CreateRenderer(window, -1, SDL.RENDERER_PRESENTVSYNC)
	assert(game.renderer != nil, SDL.GetErrorString())

	// game.texture = SDL_image.LoadTexture(game.renderer, "assets/sprites.png")
	// assert(game.texture != nil, SDL.GetErrorString())

	// texture_height: i32
	// texture_width: i32
	// SDL.QueryTexture(game.texture, nil, nil, &texture_width, &texture_height)
	// game.images_per_row = texture_width / BLOCK_SIZE

  create_world()

	event: SDL.Event
	loop: for {
	  keyboard.pressed_or_held_last_frame = keyboard.holding
		if SDL.PollEvent(&event) {
			if !handle_key_press(event) {
				break
			}
		}

    //fmt.print(keyboard.pressed_or_held_last_frame)

		@(static)
		lastUpdate: time.Tick
		ms_since_last_update := f32(time.duration_milliseconds(time.tick_since(lastUpdate)))
		lastUpdate = time.tick_now()

		update_world(ms_since_last_update)
    render_world()

    free_all(context.temp_allocator)
	}
}
