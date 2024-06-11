package game

import rl "vendor:raylib"

Vec2 :: [2]f32
IVec2 :: [2]i32

ivec2 :: proc(x, y: $T) -> IVec2 {
    return IVec2{i32(x), i32(y)}
}

lin_to_xy :: proc(lin, max: $T) -> (x, y: T) {
    x = lin / max
    y = lin % max
    return
}

vec2_to_lin :: proc(v: [2]$T, max: T) -> T {
    return xy_to_lin(v.x, v.y, max)
}

xy_to_lin :: proc(x, y, max: $T) -> T {
    return x * max + y
}

ivec2_to_vec2 :: proc(v: IVec2) -> Vec2 {
    return Vec2{f32(v.x), f32(v.y)}
}

vec2_to_ivec2 :: proc(v: Vec2) -> IVec2 {
    return IVec2{i32(v.x), i32(v.y)}
}

is_mouse_in_world_bounds :: proc(camera: rl.Camera2D) -> bool {
    mouse_position := rl.GetMousePosition()
    world_position := rl.GetScreenToWorld2D(mouse_position, camera)
    return world_position.x >= 0 &&
        world_position.y >= 0 &&
        world_position.x < WORLD_SIZE * CHUNK_SIZE * BLOCK_SIZE &&
        world_position.y < WORLD_SIZE * CHUNK_SIZE * BLOCK_SIZE
}

get_mouse_block_position :: proc(camera: rl.Camera2D) -> IVec2 {
    mouse_position := rl.GetMousePosition()
    world_position := rl.GetScreenToWorld2D(mouse_position, camera)
    block_position := world_position / BLOCK_SIZE
    return vec2_to_ivec2(block_position)
}

is_chunk_in_world_bounds :: proc(chunk_position: IVec2) -> bool {
    return chunk_position.x >= 0 &&
        chunk_position.y >= 0 &&
        chunk_position.x < WORLD_SIZE &&
        chunk_position.y < WORLD_SIZE
}
