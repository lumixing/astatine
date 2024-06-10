package game

import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
    using transform: Transform,
    using sprite: Sprite,
    using body: DynamicBody,
}

player_input :: proc(player: ^Player) {
    player.input = {}
    if rl.IsKeyDown(.D) do player.input.x += 1
    if rl.IsKeyDown(.A) do player.input.x -= 1
    if rl.IsKeyDown(.S) do player.input.y += 1
    if rl.IsKeyDown(.W) do player.input.y -= 1
}
