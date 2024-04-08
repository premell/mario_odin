package main

import "core:fmt"


create_world :: proc(){
  player = Player{
    hit_box = {1,1}
  }

  world = World {
    blocks = {
      {
        type = BLOCK.ground,
        position = {-20,-20},
        hit_box = {
          height = 20,
          width = 1000
        }
      },
      // {
      //   type = BLOCK.ground,
      //   position = {5,5},
      //   hit_box = {
      //     height = 1,
      //     width = 1
      //   }
      // }
    }
  }


  fmt.print(world.blocks)
}

// player_state := PlayerState{
// hit_box = {
//       height = 1,
//       width = 1,
//
// }
// }
//
//
//
//
//
//
// world_state := WorldState{
//   blocks = {
//     {
// type = BLOCK_TYPE.ground,
//       position = {-20,-20},
// hit_box = {
//       height = 20,
//       width = 1000,
//
// }
//     },
//     {
// type = BLOCK_TYPE.ground,
//       position = {5,5},
// hit_box = {
//       height = 1,
//       width = 1,
//
// }
//     }
//   }
// }
//
