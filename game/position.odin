package game

Vec2 :: [2]f32
IVec2 :: [2]i32

lin_to_xy :: proc(lin, max: $T) -> (x, y: T) {
    x = lin / max
    y = lin % max
    return
}

ivec2_to_vec :: proc(v: IVec2) -> Vec2 {
    return Vec2{f32(v.x), f32(v.y)}
}
