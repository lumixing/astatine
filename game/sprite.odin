package game

import rl "vendor:raylib"

Sprite :: struct {
    offset: Vec2,
    rect: rl.Rectangle,
}

@(private="file")
entity_render_atom :: proc(ent: $T) {
    rl.DrawTextureRec(game.textures.blocks, ent.sprite.rect, ent.transform.position + ent.sprite.offset, rl.WHITE)
}

entity_render :: proc(entity: Entity) {
    switch ent in entity.type {
    case ^Player: entity_render_atom(ent)
    case ^Item:   entity_render_atom(ent)
    }
}
