package game

import ns "core:math/noise"

WORLD_SIZE :: 16
WORLD_SIZE_SQ :: WORLD_SIZE * WORLD_SIZE

World :: struct {
    chunks: [dynamic]Chunk,
    player: Entity,
    entities: [dynamic]Entity, // split to chunks later?
    colls: [dynamic]IVec2, // split to chunks later for opt?
    loaded_chunks: [dynamic]i32,
}

world_new :: proc() {
    for ci in 0..<WORLD_SIZE_SQ {
        cx, cy := lin_to_xy(ci, WORLD_SIZE)
        chunk: Chunk
        chunk.position = IVec2{i32(cx), i32(cy)}
        append(&game.world.chunks, chunk)
    }

    world_gen()
    world_update_colls()
}

world_gen :: proc() {
    NOISE_SCALE :: 10

    blocks := WORLD_SIZE * CHUNK_SIZE
    for x in 0..<blocks {
        for y in 0..<blocks {
            world_set_block(ivec2(x, y), .DIRT, true)

            n := ns.noise_2d(0, {f64(x), f64(y)} / NOISE_SCALE)

            block: Block
            if n < 0 do block = .AIR
            else if n < 0.3 do block = .DIRT
            else do block = .STONE

            world_set_block(ivec2(x, y), block)
        }
    }
}

world_update_colls :: proc() {
    clear(&game.world.colls)

    for ci in game.world.loaded_chunks {
        chunk := game.world.chunks[ci]
        for block, rbi in chunk.blocks {
            if block == .AIR do continue
            rbx, rby := lin_to_xy(rbi, CHUNK_SIZE)
            x := BLOCK_SIZE * (chunk.position.x * CHUNK_SIZE + i32(rbx))
            y := BLOCK_SIZE * (chunk.position.y * CHUNK_SIZE + i32(rby))
            append(&game.world.colls, IVec2{x, y})
        }
    }
}

world_get_block :: proc(block_position: IVec2, wall := false) -> Block {
    ci := xy_to_lin(block_position.x/CHUNK_SIZE, block_position.y/CHUNK_SIZE, WORLD_SIZE)
    rbi := xy_to_lin(block_position.x%CHUNK_SIZE, block_position.y%CHUNK_SIZE, CHUNK_SIZE)
    if wall {
        return game.world.chunks[ci].walls[rbi]
    } else {
        return game.world.chunks[ci].blocks[rbi]
    }
}

world_set_block :: proc(block_position: IVec2, block: Block, wall := false) {
    ci := xy_to_lin(block_position.x/CHUNK_SIZE, block_position.y/CHUNK_SIZE, WORLD_SIZE)
    rbi := xy_to_lin(block_position.x%CHUNK_SIZE, block_position.y%CHUNK_SIZE, CHUNK_SIZE)
    if wall {
        game.world.chunks[ci].walls[rbi] = block
    } else {
        game.world.chunks[ci].blocks[rbi] = block
    }
}

world_render :: proc() {
    for ci in game.world.loaded_chunks {
        chunk := game.world.chunks[ci]
        chunk_render(chunk)
    }
}
