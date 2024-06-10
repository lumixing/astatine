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
    player.rect = {0, 8, 8, 16}
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
        world_set_block(world, block_pos, .AIR)
    }
    if rl.IsMouseButtonDown(.RIGHT) && is_mouse_in_world_bounds(camera) {
        block_pos := get_mouse_block_position(camera)
        world_set_block(world, block_pos, .DIRT)
    }
}
