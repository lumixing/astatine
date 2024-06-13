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

world_new :: proc() -> World {
    world: World

    for ci in 0..<WORLD_SIZE_SQ {
        cx, cy := lin_to_xy(ci, WORLD_SIZE)
        chunk: Chunk
        chunk.position = IVec2{i32(cx), i32(cy)}
        append(&world.chunks, chunk)
    }

    world_gen(&world)
    world_update_colls(&world)

    return world
}

world_gen :: proc(world: ^World) {
    NOISE_SCALE :: 10

    blocks := WORLD_SIZE * CHUNK_SIZE
    for x in 0..<blocks {
        for y in 0..<blocks {
            world_set_block(world, ivec2(x, y), .DIRT, true)

            n := ns.noise_2d(0, {f64(x), f64(y)} / NOISE_SCALE)

            block: Block
            if n < 0 do block = .AIR
            else if n < 0.3 do block = .DIRT
            else do block = .STONE

            world_set_block(world, ivec2(x, y), block)
        }
    }
}

world_update_colls :: proc(world: ^World) {
    clear(&world.colls)

    for ci in world.loaded_chunks {
        chunk := world.chunks[ci]
        for block, rbi in chunk.blocks {
            if block == .AIR do continue
            rbx, rby := lin_to_xy(rbi, CHUNK_SIZE)
            x := BLOCK_SIZE * (chunk.position.x * CHUNK_SIZE + i32(rbx))
            y := BLOCK_SIZE * (chunk.position.y * CHUNK_SIZE + i32(rby))
            append(&world.colls, IVec2{x, y})
        }
    }
}

world_get_block :: proc(world: World, block_position: IVec2, wall := false) -> Block {
    ci := xy_to_lin(block_position.x/CHUNK_SIZE, block_position.y/CHUNK_SIZE, WORLD_SIZE)
    rbi := xy_to_lin(block_position.x%CHUNK_SIZE, block_position.y%CHUNK_SIZE, CHUNK_SIZE)
    if wall {
        return world.chunks[ci].walls[rbi]
    } else {
        return world.chunks[ci].blocks[rbi]
    }
}

world_set_block :: proc(world: ^World, block_position: IVec2, block: Block, wall := false) {
    ci := xy_to_lin(block_position.x/CHUNK_SIZE, block_position.y/CHUNK_SIZE, WORLD_SIZE)
    rbi := xy_to_lin(block_position.x%CHUNK_SIZE, block_position.y%CHUNK_SIZE, CHUNK_SIZE)
    if wall {
        world.chunks[ci].walls[rbi] = block
    } else {
        world.chunks[ci].blocks[rbi] = block
    }
}

world_render :: proc(world: World) {
    for ci in world.loaded_chunks {
        chunk := world.chunks[ci]
        chunk_render(chunk)
    }
}
