package game

import rl "vendor:raylib"
import rand "core:math/rand"

CHUNK_SIZE :: 16
CHUNK_SIZE_SQ :: CHUNK_SIZE * CHUNK_SIZE

Chunk :: struct {
    position: IVec2,
    blocks: [CHUNK_SIZE_SQ]Block,
}

chunk_render :: proc(chunk: Chunk) {
    for block, rbi in chunk.blocks {
        rbx, rby := lin_to_xy(rbi, CHUNK_SIZE)

        if block != .AIR {
            x := BLOCK_SIZE * (chunk.position.x * CHUNK_SIZE + i32(rbx))
            y := BLOCK_SIZE * (chunk.position.y * CHUNK_SIZE + i32(rby))
            rl.DrawTextureRec(texture, block_to_rect(block), {f32(x), f32(y)}, rl.WHITE)
        }
    }
}
