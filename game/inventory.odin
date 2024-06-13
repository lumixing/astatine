package game

Inventory :: struct {
    data: [9]InventoryItem,
    selected: int,
}

InventoryItem :: struct {
    item: Block,
    amount: int,
}

inventory_add_item :: proc(inventory: ^Inventory, item: InventoryItem) {
    if item_index, has_item := inventory_get_item_index(inventory^, item.item).(int); has_item {
        inventory.data[item_index].amount += 1
    } else if empty_index, has_empty := inventory_get_first_empty_slot(inventory^).(int); has_empty {
        inventory.data[empty_index] = item
    }
}

inventory_get_item_index :: proc(inventory: Inventory, item: Block) -> Maybe(int) {
    for it, i in inventory.data {
        if it.item == item { // cant do item.item :(, maybe ditch using
            return i
        }
    }

    return nil
}

inventory_get_first_empty_slot :: proc(inventory: Inventory) -> Maybe(int) {
    for it, i in inventory.data {
        if it.item == .AIR || it.amount == 0 {
            return i
        }
    }

    return nil
}

inventory_get_current :: proc(inventory: Inventory) -> InventoryItem {
    return inventory.data[inventory.selected]
}

inventory_decrease_current :: proc(inventory: ^Inventory) {
    inventory.data[inventory.selected].amount -= 1

    if inventory.data[inventory.selected].amount == 0 {
        inventory.data[inventory.selected] = {}
    }
}
