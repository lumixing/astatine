package game

import "core:fmt"
import la "core:math/linalg"
import rl "vendor:raylib"

CAMERA_LERP :: 13
texture: rl.Texture2D

main :: proc() {
    rl.SetWindowState({.WINDOW_ALWAYS_RUN})
    rl.InitWindow(800, 600, "astatine [debug]")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    camera := rl.Camera2D{{}, {}, 0, 2}

    world := world_new()

    player := new_entity(Player, &world)
    player.position.y = -100
    player.position.x = 350
    player.color = rl.BLUE
    player.size = {8, 16}
    world.player = player

    image := rl.LoadImage("assets/block_atlas.png")
    texture = rl.LoadTextureFromImage(image)

    for !rl.WindowShouldClose() && true {
        delta := rl.GetFrameTime()

        if rl.IsKeyPressed(.F1) {
            fmt.println("reloaded textures!")
            image = rl.LoadImage("assets/block_atlas.png")
            texture = rl.LoadTextureFromImage(image)
        }

        if rl.IsMouseButtonDown(.LEFT) && is_mouse_in_world_bounds(camera) {
            block_pos := get_mouse_block_position(camera)
            world_set_block(&world, block_pos, .AIR)
        }
        if rl.IsMouseButtonDown(.RIGHT) && is_mouse_in_world_bounds(camera) {
            block_pos := get_mouse_block_position(camera)
            world_set_block(&world, block_pos, .DIRT)
        }

        player_input(player)
        entity_physics(player, world.colls[:])
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
