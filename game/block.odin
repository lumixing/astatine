package game

import rl "vendor:raylib"

BLOCK_SIZE :: 8

Block :: enum {
    AIR, GRASS, DIRT, STONE,
}

block_to_rect :: proc(block: Block) -> rl.Rectangle {
    switch block {
        case .AIR:   return {}
        case .GRASS: return {0,0,8,8}
        case .DIRT:  return {8,0,8,8}
        case .STONE: return {16,0,8,8}
        case: return {}
    }
}
