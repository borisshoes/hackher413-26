extends Sprite2D

# Potion ID -> {x_offset, y_offset} mapping
var potion_offsets = {
	2: Vector2(32, 0),   # Regen
	3: Vector2(16, 0),   # Alakitty
	4: Vector2(0, 0),    # Spiwits
	5: Vector2(48, 32),  # Stimmewlants
	6: Vector2(48, 0),   # Swiftnuss
}

func set_item_id(item_id: int):
	if potion_offsets.has(item_id):
		var offset = potion_offsets[item_id]
		region_rect = Rect2(offset.x, offset.y, 16, 16)
