package game

import "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

CAMERA_LERP :: 13

texture: rl.Texture2D
camera: rl.Camera2D
render_vec: Vec2
world: World
player: ^Player

string_to_buffer :: proc(cstr: cstring) -> [256]byte {
    buf: [256]byte
    str := string(cstr)
    for char, i in str {
        if i >= 256 do break
        buf[i] = byte(char)
    }
    return buf
}

main :: proc() {
    rl.SetTraceLogLevel(.WARNING)
    rl.SetWindowState({.WINDOW_ALWAYS_RUN, .WINDOW_RESIZABLE})
    rl.InitWindow(800, 600, "astatine [debug]")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)
    rl.GuiLoadStyle("assets/light.rgs")

    init()

    for !rl.WindowShouldClose() {
        input()
        update()
        
        rl.BeginDrawing()
            rl.BeginMode2D(camera)
                rl.ClearBackground(rl.SKYBLUE)
                render()
            rl.EndMode2D()
            render_ui()
            // clearing text doesnt work if its in a proc, idk why
            if console_shown {
                if str == ";" {
                    buf: [256]byte
                    str = cstring(&buf[0])
                }
                if rl.GuiTextBox({0, render_vec.y-32, 512, 32}, str, 256, true) {
                    console_command()
                    buf: [256]byte
                    str = cstring(&buf[0])
                    console_shown = false
                }
            }
        rl.EndDrawing()
    }
}

init :: proc() {
    camera = rl.Camera2D{{}, {}, 0, 2}

    world = world_new()
    player = player_new(&world)

    image := rl.LoadImage("assets/block_atlas.png")
    texture = rl.LoadTextureFromImage(image)
}

input :: proc() {
    if !console_shown {
        player_input(player, camera, &world)
    }

    debug_input()
}

update :: proc() {
    time := rl.GetTime()
    delta := rl.GetFrameTime()

    player_update_chunks(player^, &world)
    for &entity in world.entities {
        entity_physics(&entity, world.colls[:], delta)
        item_pickup(&entity, &world)
        #partial switch ent in entity.type {
            case ^Item:
                ent.offset.y = math.sin_f32(f32(time) * 5 + f32(ent.id)) - 1
        }
    }

    render_vec = {f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())}
    new_camera_position := (-player.position - player.size / 2) * camera.zoom + render_vec / 2
    camera.offset = la.lerp(camera.offset, new_camera_position, CAMERA_LERP * delta)
}

render :: proc() {
    world_render(world)
    for entity in world.entities {
        entity_render(entity)
    }

    debug_render()
}

render_ui :: proc() {
    rl.DrawFPS(0, 0)
    render_debug_ui()
}
