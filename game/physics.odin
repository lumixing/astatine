package game

import "core:math"
import la "core:math/linalg"

DynamicBody :: struct {
    velocity: Vec2,
    size: Vec2,
    input: Vec2,
    grounded: bool,
}

yay :: proc(ent: $T, delta: f32) {
    ent.body.velocity.y = la.lerp(ent.body.velocity.y, 500, 2 * delta)

        if ent.body.input.x == 0 {
            ent.body.velocity.x = la.lerp(ent.body.velocity.x, 0, 20 * delta)
        } else {
            ent.body.velocity.x = la.lerp(ent.body.velocity.x, ent.body.input.x * 200, 10 * delta)
        }

        if math.abs(ent.body.velocity.x) < 0.1 {
            ent.body.velocity.x = 0
        }

        if ent.body.input.y == -1 && ent.body.grounded {
            ent.body.velocity.y = -220
            ent.body.grounded = false
        }

        ent.transform.position += ent.body.velocity * delta

        should_ground := false

        for block_pos in game.world.colls {
            coll := collide_aabb(ent.transform.position, ent.body.size, ivec2_to_vec2(block_pos), {BLOCK_SIZE, BLOCK_SIZE})
            #partial switch coll {
            case .Bottom:
                should_ground = true
                ent.body.velocity.y = 0
                ent.transform.position.y = f32(block_pos.y) - ent.body.size.y
            case .Top:
                ent.body.velocity.y = 0
                ent.transform.position.y = f32(block_pos.y) + BLOCK_SIZE
            case .Right:
                ent.body.velocity.x = 0
                ent.transform.position.x = f32(block_pos.x) - BLOCK_SIZE
            case .Left:
                ent.body.velocity.x = 0
                ent.transform.position.x = f32(block_pos.x) + ent.body.size.x
            }
        }

        ent.body.grounded = should_ground
}

entity_physics :: proc(entity: ^Entity, delta: f32) {
    switch ent in entity.type {
    case ^Player: yay(ent, delta)
    case ^Item:   yay(ent, delta)
    }
}

CollisionType :: enum {
    None,
    Top,
    Bottom,
    Left,
    Right,
    Inside,
}

collide_aabb :: proc(a_translation: Vec2, a_size: Vec2, b_translation: Vec2, b_size: Vec2) -> CollisionType {
    a_min := a_translation
    a_max := Vec2{a_translation.x + a_size.x, a_translation.y + a_size.y}
    b_min := b_translation
    b_max := Vec2{b_translation.x + b_size.x, b_translation.y + b_size.y}

    if a_max.x <= b_min.x || a_min.x >= b_max.x || a_max.y <= b_min.y || a_min.y >= b_max.y {
        return .None
    }

    if a_min.x >= b_min.x && a_max.x <= b_max.x && a_min.y >= b_min.y && a_max.y <= b_max.y {
        return .Inside
    }

    dx1 := a_max.x - b_min.x
    dx2 := b_max.x - a_min.x
    dy1 := a_max.y - b_min.y
    dy2 := b_max.y - a_min.y

    overlap_x := dx1 < dx2 ? dx1 : dx2
    overlap_y := dy1 < dy2 ? dy1 : dy2

    if overlap_x < overlap_y {
        if a_min.x < b_min.x {
            return .Right
        } else {
            return .Left
        }
    } else {
        if a_min.y < b_min.y {
            return .Bottom
        } else {
            return .Top
        }
    }
}
