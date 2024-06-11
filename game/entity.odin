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

Item :: struct {
    using entity: Entity,
    using transform: Transform,
    using sprite: Sprite,
    using body: DynamicBody,
}

new_entity :: proc($T: typeid, world: ^World) -> ^T {
    @(static) id := 0
    id += 1

    entity := new(T)
    entity.id = id
    entity.type = entity

    append(&world.entities, entity)

    return entity
}
