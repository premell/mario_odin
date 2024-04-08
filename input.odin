package main

import SDL "vendor:sdl2"
import "core:fmt"

handle_key_press::proc(event: SDL.Event) -> bool{
			if event.type == SDL.EventType.QUIT {return false}

			if event.type == SDL.EventType.KEYDOWN {
				if event.key.keysym.scancode == SDL.Scancode.A {
					keyboard_state.left.pressed_since_last_update = true
					keyboard_state.left.currently_pressed = true
				}

				if event.key.keysym.scancode == SDL.Scancode.W {
					keyboard_state.jump.pressed_since_last_update = true
					keyboard_state.jump.currently_pressed = true
				}

				if event.key.keysym.scancode == SDL.Scancode.D {
					keyboard_state.right.pressed_since_last_update = true
					keyboard_state.right.currently_pressed = true
				}

				if event.key.keysym.scancode == SDL.Scancode.S {
					keyboard_state.crouch.pressed_since_last_update = true
					keyboard_state.crouch.currently_pressed = true
				}

				if event.key.keysym.scancode == SDL.Scancode.ESCAPE {
          return false
				}
			}

			if event.type == SDL.EventType.KEYUP {
				if event.key.keysym.scancode == SDL.Scancode.A {
					keyboard_state.left.currently_pressed = false
				}

				if event.key.keysym.scancode == SDL.Scancode.W {
					keyboard_state.jump.currently_pressed = false
				}

				if event.key.keysym.scancode == SDL.Scancode.D {
					keyboard_state.right.currently_pressed = false
				}

				if event.key.keysym.scancode == SDL.Scancode.S {
					keyboard_state.crouch.currently_pressed = false
				}
        // fmt.println(event.key.keysym.scancode)
        // fmt.println(keyboard_state)
			}

      
      return true
}

