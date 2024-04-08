package main

import SDL "vendor:sdl2"
import "core:time"

DIRECTION :: enum {
  LEFT,
  RIGHT, 
  UP, 
  DOWN,
  NONE
}


Game :: struct {
	renderer: ^SDL.Renderer,
}

// always a rectangle for now...
HitBox :: struct {
  width: int,
  height: int
}

CREATURE_TYPE :: enum {
  goomba, 
  koopa, 
  bullet_bill,
  pipe_trap
}

VERTICAL_MOVEMENT_STATE :: enum {
  grounded, 
  falling,
  jumping // jumping is only the part until you reach the top of the arc. After that you enter into falling mode
}

Creature :: struct {
  creature_pointer: ^int,
  creature_type: CREATURE_TYPE,
  hit_box: HitBox,
  vertical_movement_state: VERTICAL_MOVEMENT_STATE,
	has_jumped, facing_left_else_right: bool,
  health: int,
	position, velocity: [2]f32,
  
  //, acceleration, TODO should they even have acceleration?
}

Player :: struct {
  is_crouching: bool,
  creature_pointer: ^int,
  creature_type: CREATURE_TYPE,
  hit_box: HitBox,
  vertical_movement_state: VERTICAL_MOVEMENT_STATE,
	has_jumped, facing_left_else_right: bool,
  health: int,
	position, velocity, acceleration: [2]f32,
}

// ENUMS
BLOCK_TYPE :: enum {
	ground,
  fire,
  wall,
  door
}

// STRUCTS
Block :: struct {
  type: BLOCK_TYPE,
  // always bottom left
  position: [2]f32,
  hit_box: HitBox
}

World :: struct {
	// blocks are collidable 
	blocks:            []Block,
	world_update_tick: time.Tick,
}

KeyState :: struct {
	pressed_since_last_update: bool,
	currently_pressed:         bool,
}
KeyboardState :: struct {
	left:   KeyState,
	right:  KeyState,
	jump:   KeyState,
	crouch: KeyState,
}
