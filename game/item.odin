package game

Item :: struct {
    using entity: Entity,
    using transform: Transform,
    using sprite: Sprite,
    using body: DynamicBody,
    using inventory_item: InventoryItem,
}

item_pickup :: proc(entity: ^Entity, world: ^World) {
    #partial switch ent in entity.type {
        case ^Player: check_item_coll(ent, world)
    }
}

check_item_coll :: proc(ent: $T, world: ^World) {
    for e, i in world.entities {
        item, is_item := e.type.(^Item)
        if !is_item do continue

        coll := collide_aabb(ent.position, ent.size, item.position, item.size)
        if coll == .None do continue

        inventory_add_item(&ent.inventory, {item.inventory_item.item, 1})
        ordered_remove(&world.entities, i)
    }
}
