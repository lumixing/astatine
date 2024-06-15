package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Player :: struct {
    using entity: Entity,
    using transform: Transform,
    using sprite: Sprite,
    using body: DynamicBody,
    using inventory: Inventory,
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

    player.selected -= int(rl.GetMouseWheelMove())
    if player.selected < 0 do player.selected = 8
    if player.selected > 8 do player.selected = 0

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
            item.inventory_item = {block, 1}
            world_update_colls(world)
        }
    }
    if rl.IsMouseButtonDown(.RIGHT) && is_mouse_in_world_bounds(camera) {
        block_pos := get_mouse_block_position(camera)
        block := world_get_block(world^, block_pos)
        current_item := inventory_get_current(player.inventory)
        if block == .AIR && current_item.item != .AIR {
            world_set_block(world, block_pos, current_item.item)
            inventory_decrease_current(&player.inventory)
            world_update_colls(world)
        }
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

render_player_inventory :: proc(player: Player) {
    @(static) v: Vec2
    w: f32 = 32*9+8*10
    h: f32 = 32+2*8
    x: f32 = (render_vec.x-w)/2
    y: f32 = render_vec.y-h
    rl.GuiGrid({x, y, w, h}, "inventory", 1, 9, &v)
    
    for item, i in player.data {
        rect := block_to_rect(item.item)
        rect.x *= 4
        rect.y *= 4
        rect.width *= 4
        rect.height *= 4
        fi := f32(i)
        ix: f32 = x+8+fi*(32+8)
        iy: f32 = y+8
        amount_text := strings.clone_to_cstring(fmt.tprint(item.amount))
        defer delete(amount_text)

        rl.DrawTextureRec(big_texture, rect, {ix, iy}, rl.WHITE)
        rl.DrawText(amount_text, i32(ix), i32(iy), 20, rl.BLACK)

        if player.selected == i {
            rl.DrawRectangleLinesEx({ix-8, iy-8, 32+16, 32+16}, 2, rl.RED)
        }
    }
    // debug(v)
}
