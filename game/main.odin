package game

import "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

CAMERA_LERP :: 13

GameState :: struct {
    textures: Textures,
    camera: rl.Camera2D,
    screen: Vec2,
    world: World,
    player: ^Player,
}

Textures :: struct {
    blocks: rl.Texture2D,
    big_blocks: rl.Texture2D,
}

game: GameState
// texture: rl.Texture2D
// big_texture: rl.Texture2D
// camera: rl.Camera2D
// render_vec: Vec2
// world: World
// player: ^Player

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
            rl.BeginMode2D(game.camera)
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
                if rl.GuiTextBox({0, game.screen.y-32, 512, 32}, str, 256, true) {
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
    game.camera = rl.Camera2D{{}, {}, 0, 2}
    game.world = world_new()
    game.player = player_new(&game.world)

    image := rl.LoadImage("assets/block_atlas.png")
    game.textures.blocks = rl.LoadTextureFromImage(image)

    big_image := image
    rl.ImageResizeNN(&big_image, 256*4, 256*4)
    game.textures.big_blocks = rl.LoadTextureFromImage(big_image)
}

input :: proc() {
    if !console_shown {
        player_input(game.player, game.camera, &game.world)
    }

    debug_input()
}

update :: proc() {
    time := rl.GetTime()
    delta := rl.GetFrameTime()

    player_update_chunks(game.player^, &game.world)
    for &entity in game.world.entities {
        entity_physics(&entity, game.world.colls[:], delta)
        item_pickup(&entity, &game.world)
        #partial switch ent in entity.type {
            case ^Item:
                ent.sprite.offset.y = math.sin_f32(f32(time) * 5 + f32(ent.entity.id)) - 1
        }
    }

    game.screen = {f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())}
    new_camera_position := (-game.player.transform.position - game.player.body.size / 2) * game.camera.zoom + game.screen / 2
    game.camera.offset = la.lerp(game.camera.offset, new_camera_position, CAMERA_LERP * delta)
}

render :: proc() {
    world_render(game.world)
    for entity in game.world.entities {
        entity_render(entity)
    }

    debug_render()
}

render_ui :: proc() {
    render_player_inventory(game.player^)
    rl.DrawFPS(0, 0)
    render_debug_ui()
}
