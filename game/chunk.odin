package game

import rl "vendor:raylib"

CHUNK_SIZE :: 16
CHUNK_SIZE_SQ :: CHUNK_SIZE * CHUNK_SIZE

Chunk :: struct {
    position: IVec2,
    blocks: [CHUNK_SIZE_SQ]Block,
    walls: [CHUNK_SIZE_SQ]Block,
}

chunk_render :: proc(chunk: Chunk) {
    for rbi in 0..<CHUNK_SIZE_SQ {
        rbx, rby := lin_to_xy(rbi, CHUNK_SIZE)
        x := BLOCK_SIZE * (chunk.position.x * CHUNK_SIZE + i32(rbx))
        y := BLOCK_SIZE * (chunk.position.y * CHUNK_SIZE + i32(rby))

        block := chunk.blocks[rbi]
        if block != .AIR {
            rl.DrawTextureRec(game.textures.blocks, block_to_rect(block), {f32(x), f32(y)}, rl.WHITE)
        }
        
        wall := chunk.walls[rbi]
        if wall != .AIR && block == .AIR {
            rl.DrawTextureRec(game.textures.blocks, block_to_rect(wall), {f32(x), f32(y)}, rl.GRAY)
        }
    }
}
