package main

import "core:time"
import SDL "vendor:sdl2"

DIRECTION :: enum {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	NONE,
}

Game :: struct {
	renderer: ^SDL.Renderer,
}

// always a rectangle for now...
HitBox :: struct {
	width:  f32,
	height: f32,
}

CREATURE_TYPE :: enum {
	goomba, // start with this one only...
	koopa,
	bullet_bill,
	pipe_trap,
}

VERTICAL_MOVEMENT_STATE :: enum {
	grounded,
	falling,
	jumping, // jumping is only the part until you reach the top of the arc. After that you enter into falling mode
}

Creature :: struct {
	//creature_pointer:                   ^int,
	type:                      CREATURE_TYPE,
	hit_box:                            HitBox,
	vertical_movement_state:            VERTICAL_MOVEMENT_STATE,
	has_jumped, facing_left_else_right: bool,
	health:                             int,

	// position is bottom left corner of the hitbox
	position, velocity:                 [2]f32,

	//, acceleration, TODO should they even have acceleration?
}

Player :: struct {
	is_crouching:                       bool,
	//creature_pointer:                   ^int,
	type:                      CREATURE_TYPE,
	hit_box:                            HitBox,
	vertical_movement_state:            VERTICAL_MOVEMENT_STATE,
	has_jumped, facing_left_else_right: bool,
	health:                             int,
	// position is bottom left corner of the hitbox
	position, velocity, acceleration:   [2]f32,
}

// ENUMS
BLOCK :: enum {
	ground,
	fire,
	wall,
	door,
}

// STRUCTS
Block :: struct {
	type:     BLOCK,
	// always bottom left
	position: [2]f32,
	hit_box:  HitBox,
}

World :: struct {
	// blocks are collidable
	blocks:    [dynamic]Block,
	creatures: [dynamic]Creature,
	//world_update_tick: time.Tick,
}

// KeyState :: struct {
// 	pressed_since_last_update: bool,
// 	currently_pressed:         bool,
// }

Action :: enum {
	LEFT,
	RIGHT,
	JUMP,
	CROUCH,
}

Keyboard :: struct {
	holding:                    [dynamic]Action,
	pressed_or_held_last_frame: [dynamic]Action,
}

Collision :: struct {
// direction is the side which has the closest distance to the edge. I dont know if this is
// actually true but its quick and dirty
	direction: DIRECTION,
	position_to_escape:     f32,
}
