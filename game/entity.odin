package game

Entity :: struct {
    id: int,
    type: EntityType
}

Transform :: struct {
    position: Vec2,
}

EntityType :: union {
    ^Player,
    ^Item,
}

new_entity :: proc($T: typeid) -> ^T {
    @(static) id := 0
    id += 1

    entity := new(T)
    entity.entity.id = id
    entity.entity.type = entity

    append(&game.world.entities, entity.entity)

    return entity
}
