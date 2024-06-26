package game

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
                    buf: [CONSOLE_BUFFER_SIZE]byte
                    str = cstring(&buf[0])
                }
                if rl.GuiTextBox({0, game.screen.y-32, 512, 32}, str, CONSOLE_BUFFER_SIZE, true) {
                    console_command()
                    buf: [CONSOLE_BUFFER_SIZE]byte
                    str = cstring(&buf[0])
                    console_shown = false
                }
            }
        rl.EndDrawing()
    }
}

init :: proc() {
    game.camera = rl.Camera2D{{}, {}, 0, 2}
    world_new()
    game.player = player_new()

    image := rl.LoadImage("assets/block_atlas.png")
    game.textures.blocks = rl.LoadTextureFromImage(image)

    big_image := image
    rl.ImageResizeNN(&big_image, 256*4, 256*4)
    game.textures.big_blocks = rl.LoadTextureFromImage(big_image)
}

input :: proc() {
    if !console_shown {
        player_input()
    }

    debug_input()
}

update :: proc() {
    time := f32(rl.GetTime())
    delta := rl.GetFrameTime()
    game.screen = {f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())}

    player_update_chunks()
    for &entity in game.world.entities {
        entity_physics(&entity, delta)
        item_pickup(&entity)
        item_animation(&entity, time)
    }

    new_camera_position := (-game.player.transform.position - game.player.body.size / 2) * game.camera.zoom + game.screen / 2
    game.camera.offset = la.lerp(game.camera.offset, new_camera_position, CAMERA_LERP * delta)
}

render :: proc() {
    world_render_loaded_chunks()
    world_render_entities()

    debug_render()
}

render_ui :: proc() {
    player_render_inventory()
    rl.DrawFPS(0, 0)
    render_debug_ui()
}
