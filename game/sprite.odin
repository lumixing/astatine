package game

import rl "vendor:raylib"

Sprite :: struct {
    rect: rl.Rectangle,
}

entity_render :: proc(entity: Entity) {
    switch ent in entity.type {
    case ^Player:
        rl.DrawTextureRec(texture, ent.rect, ent.position, rl.WHITE)
    }
}
