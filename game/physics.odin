package game

import "core:math"
import la "core:math/linalg"

DynamicBody :: struct {
    velocity: Vec2,
    size: Vec2,
    input: Vec2,
    grounded: bool,
}

yay :: proc(ent: $T, colls: []IVec2, delta: f32) {
    ent.velocity.y = la.lerp(ent.velocity.y, 500, 2 * delta)

        if ent.input.x == 0 {
            ent.velocity.x = la.lerp(ent.velocity.x, 0, 20 * delta)
        } else {
            ent.velocity.x = la.lerp(ent.velocity.x, ent.input.x * 200, 10 * delta)
        }

        if math.abs(ent.velocity.x) < 0.1 {
            ent.velocity.x = 0
        }

        if ent.input.y == -1 && ent.grounded {
            ent.velocity.y = -220
            ent.grounded = false
        }

        ent.position += ent.velocity * delta

        should_ground := false

        for block_pos in colls {
            coll := collide_aabb(ent.position, ent.size, ivec2_to_vec2(block_pos), {BLOCK_SIZE, BLOCK_SIZE})
            #partial switch coll {
            case .Bottom:
                should_ground = true
                ent.velocity.y = 0
                ent.position.y = f32(block_pos.y) - ent.size.y
            case .Top:
                ent.velocity.y = 0
                ent.position.y = f32(block_pos.y) + BLOCK_SIZE
            case .Right:
                ent.velocity.x = 0
                ent.position.x = f32(block_pos.x) - BLOCK_SIZE
            case .Left:
                ent.velocity.x = 0
                ent.position.x = f32(block_pos.x) + ent.size.x
            }
        }

        ent.grounded = should_ground
}

entity_physics :: proc(entity: ^Entity, colls: []IVec2, delta: f32) {
    switch ent in entity.type {
    case ^Player: yay(ent, colls, delta)
    case ^Item:   yay(ent, colls, delta)
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
