package game

import "core:slice"
import rl "vendor:raylib"

buf: [256]byte
str := cstring(&buf[0])
console_shown := false
show_chunk_border := false

debug_render :: proc() {
    render_chunk_borders()
}

debug_input :: proc() {
    if rl.IsKeyPressed(.MINUS) do camera.zoom -= 0.5
    if rl.IsKeyPressed(.EQUAL) do camera.zoom += 0.5
    if rl.IsKeyPressed(.BACKSPACE) do camera.zoom = 2
    if rl.IsKeyPressed(.SEMICOLON) do console_shown = true
}

render_chunk_borders :: proc() {
    if !show_chunk_border do return

    for i in 0..<WORLD_SIZE_SQ {
        x, y := lin_to_xy(i, WORLD_SIZE)
        rl.DrawRectangleLinesEx(rl.Rectangle{
            f32(x * CHUNK_SIZE * BLOCK_SIZE),
            f32(y * CHUNK_SIZE * BLOCK_SIZE),
            f32(CHUNK_SIZE * BLOCK_SIZE),
            f32(CHUNK_SIZE * BLOCK_SIZE),
        }, 0.5/camera.zoom, rl.PINK)
    }
}

console_command :: proc() {
    if str == "chunk" {
        show_chunk_border = !show_chunk_border
    } else if str == "killitems" {
        // this is either scuffed or genius, ordered_remove has weird behavior!
        ents := slice.filter(world.entities[:], filter_items)
        world.entities = slice.to_dynamic(ents)

        filter_items :: proc(ent: Entity) -> bool {
            _, is_item := ent.type.(^Item)
            return !is_item
        }   
    } else if str == "top" {
        player.position.y = -16
    }
}
