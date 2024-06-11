package game

import "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

CAMERA_LERP :: 13

texture: rl.Texture2D

main :: proc() {
    rl.SetTraceLogLevel(.WARNING)
    rl.SetWindowState({.WINDOW_ALWAYS_RUN, .WINDOW_RESIZABLE})
    rl.InitWindow(800, 600, "astatine [debug]")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    camera := rl.Camera2D{{}, {}, 0, 2}

    world := world_new()
    player := player_new(&world)

    image := rl.LoadImage("assets/block_atlas.png")
    texture = rl.LoadTextureFromImage(image)

    for !rl.WindowShouldClose() && true {
        time := rl.GetTime()
        delta := rl.GetFrameTime()

        player_input(player, camera, &world)
        player_update_chunks(player^, &world)
        for &entity in world.entities {
            entity_physics(&entity, world.colls[:], delta)
            #partial switch ent in entity.type {
                case ^Item:
                    ent.offset.y = math.sin_f32(f32(time) * 5 + f32(ent.id)) - 1
            }
        }

        if rl.IsKeyPressed(.MINUS) do camera.zoom -= 0.5
        if rl.IsKeyPressed(.EQUAL) do camera.zoom += 0.5
        if rl.IsKeyPressed(.BACKSPACE) do camera.zoom = 2

        // debug(len(world.loaded_chunks), len(world.colls), len(world.entities))

        render_vec: Vec2 = {f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())}
        new_camera_position := (-player.position - player.size / 2) * camera.zoom + render_vec / 2
        camera.offset = la.lerp(camera.offset, new_camera_position, CAMERA_LERP * delta)
        
        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        rl.ClearBackground(rl.SKYBLUE)

        world_render(world)
        for entity in world.entities {
            entity_render(entity)
        }

        for i in 0..<WORLD_SIZE_SQ {
			x, y := lin_to_xy(i, WORLD_SIZE)
			rl.DrawRectangleLinesEx(rl.Rectangle{
				f32(x * CHUNK_SIZE * BLOCK_SIZE),
				f32(y * CHUNK_SIZE * BLOCK_SIZE),
				f32(CHUNK_SIZE * BLOCK_SIZE),
				f32(CHUNK_SIZE * BLOCK_SIZE),
			}, 0.5/camera.zoom, rl.PINK)
        }

        rl.EndMode2D()
        rl.DrawFPS(0, 0)
        rl.EndDrawing()
    }
}
