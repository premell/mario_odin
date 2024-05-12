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
	player,
}

VERTICAL_MOVEMENT_STATE :: enum {
	grounded,
	falling,
	jumping, // jumping is only the part until you reach the top of the arc. After that you enter into falling mode
}

Moveable :: struct {
	vertical_movement_state: VERTICAL_MOVEMENT_STATE,
	facing_right_else_left:  bool,
	hit_box:                 HitBox,
	// position is bottom left corner of the hitbox
	position, velocity:      [2]f32,
	creature_type:           CREATURE_TYPE,
}

Creature :: struct {
	//creature_pointer:                   ^int,
	type:          CREATURE_TYPE,
	has_jumped:    bool,
	health:        int,
	using movable: Moveable,
}

UPGRADE :: enum {
	fireball_man,
	big_boy,
	superman,
	salmonsays,
}

Player :: struct {
	//creature_pointer:                   ^int,
	is_crouching:       bool,
	has_jumped, health: int,
	acceleration:       [2]f32,
	upgrades:           [dynamic]UPGRADE,
	using movable:      Moveable,
}

BLOCK_PROPERTIES :: struct {
	bouncable: bool,
	breakable: bool,
}

// ENUMS
BLOCK :: enum {
	platform,
	ground,
	questionmark_block,
	fire,
	wall,
	door,
}

BLOCK_TYPES: map[BLOCK]BLOCK_PROPERTIES = {
	BLOCK.ground = {bouncable = true, breakable = true},
}


// STRUCTS
Block :: struct {
	type:     BLOCK,
	// always bottom left
	position: [2]f32,
	hit_box:  HitBox,
}

BouncingBlock :: struct {
	block:             ^Block,
	using movable:     Moveable,
	original_position: [2]f32,
}

Platform :: struct {
	block:                  ^Block,
	//using movable: Moveable,

	// TODO how should i  program how the platforms move? Just do horizontal movement right now...
	range:                  [2]f32, // xStart and xEnd for platform movement
	velocity:               f32,
	moving_right_else_left: bool,
}


World :: struct {
	// blocks are collidable
	blocks:          [dynamic]Block,
	bouncing_blocks: [dynamic]BouncingBlock,
	platforms:       [dynamic]Platform,
	creatures:       [dynamic]Creature,
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

	// ONLY FOR TESTING
	// SPAWN_GOOMBA,
	// RESET_WORLD
}

Keyboard :: struct {
	holding:                    [dynamic]Action,
	pressed_or_held_last_frame: [dynamic]Action,
}

Collision :: struct {
	// direction is the side which has the closest distance to the edge. I dont know if this is
	// actually true but its quick and dirty
	direction:          DIRECTION,
	position_to_escape: f32,
}
