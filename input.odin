package main

import "core:fmt"
import SDL "vendor:sdl2"


// NOTE 
// keyup and keydown

// holding => activated 
// pressed => ja activate, ja pressed
// keyup take away from holding

// if click left, inactivate right and the other way around


keydown :: proc(action: Action) {
	if !includes(keyboard.holding, action) {
		append(&keyboard.holding, action)
	}
	if !includes(keyboard.pressed_or_held_last_frame, action) {
		append(&keyboard.pressed_or_held_last_frame, action)
	}
}

handle_key_press :: proc(event: SDL.Event) -> bool {
	if event.type == SDL.EventType.QUIT {return false}


	if event.type == SDL.EventType.KEYDOWN {

		if event.key.keysym.scancode == SDL.Scancode.A {
			keydown(Action.LEFT)
      remove(&keyboard.holding, Action.RIGHT)
      remove(&keyboard.pressed_or_held_last_frame, Action.RIGHT)
		}
		if event.key.keysym.scancode == SDL.Scancode.D {
			keydown(Action.RIGHT)
      remove(&keyboard.holding, Action.LEFT)
      remove(&keyboard.pressed_or_held_last_frame, Action.LEFT)
		}

		if event.key.keysym.scancode == SDL.Scancode.SPACE {
			keydown(Action.JUMP)
		}


		if event.key.keysym.scancode == SDL.SCANCODE_LCTRL {
			keydown(Action.CROUCH)
		}

		if event.key.keysym.scancode == SDL.Scancode.ESCAPE {
			return false
		}
	}

	if event.type == SDL.EventType.KEYUP {
		if event.key.keysym.scancode == SDL.Scancode.A {
      remove(&keyboard.holding, Action.LEFT)
    }

		if event.key.keysym.scancode == SDL.Scancode.D {
      remove(&keyboard.holding, Action.RIGHT)
		}

		if event.key.keysym.scancode == SDL.Scancode.SPACE {
      remove(&keyboard.holding, Action.JUMP)
		}

		if event.key.keysym.scancode == SDL.SCANCODE_LCTRL {
      remove(&keyboard.holding, Action.CROUCH)
		}
	}

	return true
}
