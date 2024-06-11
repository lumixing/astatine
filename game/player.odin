package game

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
    using transform: Transform,
    using sprite: Sprite,
    using body: DynamicBody,
}

player_new :: proc(world: ^World) -> ^Player {
    player := new_entity(Player, world)
    player.position.y = -100
    player.position.x = 350
    player.rect = {1, 8+3, 8, 16}
    player.size = {8, 16}
    world.player = player
    return player
}

player_input :: proc(player: ^Player, camera: rl.Camera2D, world: ^World) {
    player.input = {}
    if rl.IsKeyDown(.D) do player.input.x += 1
    if rl.IsKeyDown(.A) do player.input.x -= 1
    if rl.IsKeyDown(.S) do player.input.y += 1
    if rl.IsKeyDown(.W) do player.input.y -= 1

    if rl.IsMouseButtonDown(.LEFT) && is_mouse_in_world_bounds(camera) {
        block_pos := get_mouse_block_position(camera)
        block := world_get_block(world^, block_pos)
        if block != .AIR {
            world_set_block(world, block_pos, .AIR)
            item := new_entity(Item, world)
            item.position = ivec2_to_vec2(block_pos) * BLOCK_SIZE
            item.rect = block_to_rect(block)
            item.rect.width = 4
            item.rect.height = 4
            item.size = {4, 4}
            world_update_colls(world)
        }
    }
    if rl.IsMouseButtonDown(.RIGHT) && is_mouse_in_world_bounds(camera) {
        block_pos := get_mouse_block_position(camera)
        world_set_block(world, block_pos, .DIRT)
        world_update_colls(world)
    }
}

player_update_chunks :: proc(player: Player, world: ^World) {
    @(static) last_chunk_position: i32 = -1

    chunk_position := vec2_to_ivec2(player.position / CHUNK_SIZE / BLOCK_SIZE)
    ci := vec2_to_lin(chunk_position, WORLD_SIZE)
    if last_chunk_position == chunk_position {
        return
    }

    last_chunk_position = ci
    clear(&world.loaded_chunks)

    for x in -4..=4 {
        for y in -2..=3 {
            new_chunk_position := chunk_position + ivec2(x, y)
            if !is_chunk_in_world_bounds(new_chunk_position) {
                continue
            }
            new_ci := vec2_to_lin(new_chunk_position, WORLD_SIZE)
            append(&world.loaded_chunks, new_ci)
        }
    }

    world_update_colls(world)
}
