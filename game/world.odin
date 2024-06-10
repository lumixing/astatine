package game

WORLD_SIZE :: 8
WORLD_SIZE_SQ :: WORLD_SIZE * WORLD_SIZE

World :: struct {
    chunks: [dynamic]Chunk,
    player: Entity,
    entities: [dynamic]Entity, // split to chunks later?
    colls: [dynamic]IVec2, // split to chunks later for opt?
}

world_new :: proc() -> World {
    world: World

    for ci in 0..<WORLD_SIZE_SQ {
        cx, cy := lin_to_xy(ci, WORLD_SIZE)
        chunk: Chunk
        chunk.position = IVec2{i32(cx), i32(cy)}
        chunk_fill(&chunk)
        append(&world.chunks, chunk)
    }

    world_update_colls(&world)

    return world
}

world_update_colls :: proc(world: ^World) {
    clear(&world.colls)

    for chunk in world.chunks {
        for block, rbi in chunk.blocks {
            if block == .AIR do continue
            rbx, rby := lin_to_xy(rbi, CHUNK_SIZE)
            x := BLOCK_SIZE * (chunk.position.x * CHUNK_SIZE + i32(rbx))
            y := BLOCK_SIZE * (chunk.position.y * CHUNK_SIZE + i32(rby))
            append(&world.colls, IVec2{x, y})
        }
    }
}

world_set_block :: proc(world: ^World, block_position: IVec2, block: Block) {
    ci := xy_to_lin(block_position.x/CHUNK_SIZE, block_position.y/CHUNK_SIZE, WORLD_SIZE)
    rbi := xy_to_lin(block_position.x%CHUNK_SIZE, block_position.y%CHUNK_SIZE, CHUNK_SIZE)
    world.chunks[ci].blocks[rbi] = block

    world_update_colls(world)
}

world_render :: proc(world: World) {
    for chunk in world.chunks {
        chunk_render(chunk)
    }
}
