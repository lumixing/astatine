package game

import "core:fmt"
import "core:slice"
import "core:strings"
import rl "vendor:raylib"

CONSOLE_BUFFER_SIZE :: 256

buf: [CONSOLE_BUFFER_SIZE]byte
str := cstring(&buf[0])
console_shown := false
show_chunk_border := false

debug_render :: proc() {
    render_chunk_borders()
}

debug_input :: proc() {
    if rl.IsKeyPressed(.MINUS) do game.camera.zoom -= 0.5
    if rl.IsKeyPressed(.EQUAL) do game.camera.zoom += 0.5
    if rl.IsKeyPressed(.BACKSPACE) do game.camera.zoom = 2
    if rl.IsKeyPressed(.SEMICOLON) do console_shown = true
}

@(private="file")
render_chunk_borders :: proc() {
    if !show_chunk_border do return

    for i in 0..<WORLD_SIZE_SQ {
        x, y := lin_to_xy(i, WORLD_SIZE)
        rl.DrawRectangleLinesEx(rl.Rectangle{
            f32(x * CHUNK_SIZE * BLOCK_SIZE),
            f32(y * CHUNK_SIZE * BLOCK_SIZE),
            f32(CHUNK_SIZE * BLOCK_SIZE),
            f32(CHUNK_SIZE * BLOCK_SIZE),
        }, 0.5/game.camera.zoom, rl.PINK)
    }
}

console_command :: proc() {
    switch str {
    case "chunk":
        show_chunk_border = !show_chunk_border
    case "killitems", "ki":
        ents := slice.filter(game.world.entities[:], filter_items)
        game.world.entities = slice.to_dynamic(ents)
    
        filter_items :: proc(ent: Entity) -> bool {
            _, is_item := ent.type.(^Item)
            return !is_item
        }   
    case "top":
        game.player.transform.position.y = -16
    case "clear":
        game.player.inventory = {}
    }
}

render_debug_ui :: proc() {
    rl.GuiLabel({0, 20, 100, 20}, cfmt("ent:", len(game.world.entities)))
}

cfmt :: proc(args: ..any) -> cstring {
    return strings.clone_to_cstring(fmt.tprint(..args))
}

string_to_buffer :: proc(cstr: cstring) -> [CONSOLE_BUFFER_SIZE]byte {
    buf: [CONSOLE_BUFFER_SIZE]byte
    str := string(cstr)
    for char, i in str {
        if i >= CONSOLE_BUFFER_SIZE do break
        buf[i] = byte(char)
    }
    return buf
}
