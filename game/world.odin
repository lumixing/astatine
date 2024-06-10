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

    for chunk in world.chunks {
        for block, rbi in chunk.blocks {
            if block == .AIR do continue
            rbx, rby := lin_to_xy(rbi, CHUNK_SIZE)
            x := BLOCK_SIZE * (chunk.position.x * CHUNK_SIZE + i32(rbx))
            y := BLOCK_SIZE * (chunk.position.y * CHUNK_SIZE + i32(rby))
            append(&world.colls, IVec2{x, y})
        }
    }

    return world
}

world_render :: proc(world: World) {
    for chunk in world.chunks {
        chunk_render(chunk)
    }
}
