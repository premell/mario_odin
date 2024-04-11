package main

import "core:fmt"

includes :: proc(array: [dynamic]$E, elem_to_check: E) -> bool{
  for e in array {
    if e == elem_to_check {
      return true
    }
  }

  return false
}

remove :: proc(array: ^[dynamic]$E, elem_to_remove: E) {
  for e, index in array {
    if e == elem_to_remove{
      unordered_remove(array, index)
      // currently only removes first value
      return
    }
  }
}
