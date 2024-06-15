package game

import rl "vendor:raylib"

Sprite :: struct {
    offset: Vec2,
    rect: rl.Rectangle,
}

draw :: proc(ent: $T) {
    rl.DrawTextureRec(texture, ent.sprite.rect, ent.transform.position + ent.sprite.offset, rl.WHITE)
}

// this is so fucking stupid???
entity_render :: proc(entity: Entity) {
    switch ent in entity.type {
    case ^Player: draw(ent)
    case ^Item:   draw(ent)
    }
}
