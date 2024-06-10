package game

import la "core:math/linalg"
import rl "vendor:raylib"

CAMERA_LERP :: 13

texture: rl.Texture2D

main :: proc() {
    rl.SetTraceLogLevel(.WARNING)
    rl.SetWindowState({.WINDOW_ALWAYS_RUN})
    rl.InitWindow(800, 600, "astatine [debug]")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    camera := rl.Camera2D{{}, {}, 0, 2}

    world := world_new()
    player := player_new(&world)

    image := rl.LoadImage("assets/block_atlas.png")
    texture = rl.LoadTextureFromImage(image)

    for !rl.WindowShouldClose() && true {
        delta := rl.GetFrameTime()

        player_input(player, camera, &world)
        entity_physics(player, world.colls[:], delta)

        render_vec: Vec2 = {f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())}
        new_camera_position := (-player.position - player.size / 2) * camera.zoom + render_vec / 2
        camera.offset = la.lerp(camera.offset, new_camera_position, CAMERA_LERP * delta)
        
        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        rl.ClearBackground(rl.SKYBLUE)

        world_render(world)
        entity_render(player^)

        rl.EndMode2D()
        rl.EndDrawing()
    }
}
