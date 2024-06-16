package game

import "core:math"

Item :: struct {
    entity: Entity,
    transform: Transform,
    sprite: Sprite,
    body: DynamicBody,
    inventory_item: InventoryItem,
}

item_spawn :: proc(position: Vec2, block: Block) {
    item := new_entity(Item)
    item.transform.position = position
    item.sprite.rect = block_to_rect(block)
    item.sprite.rect.width = 4
    item.sprite.rect.height = 4
    item.body.size = {4, 4}
    item.inventory_item = {block, 1}
}

@(private="file")
check_item_coll :: proc(ent: $T) {
    for e, i in game.world.entities {
        item, is_item := e.type.(^Item)
        if !is_item do continue

        coll := collide_aabb(ent.transform.position, ent.body.size, item.transform.position, item.body.size)
        if coll == .None do continue

        inventory_add_item(&ent.inventory, {item.inventory_item.item, 1})
        ordered_remove(&game.world.entities, i)
    }
}

item_pickup :: proc(entity: ^Entity) {
    #partial switch ent in entity.type {
        case ^Player: check_item_coll(ent)
    }
}

item_animation :: proc(entity: ^Entity, time: f32) {
    #partial switch ent in entity.type {
        case ^Item:
            ent.sprite.offset.y = math.sin_f32(time * 5 + f32(ent.entity.id)) - 1
    }
}
