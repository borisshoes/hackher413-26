extends Node

const ITEMS_TEXTURE = preload("res://assets/sprites/items.png")

# Potion ID -> x_offset for bottle sprites
# Bottle is at y=0, fluid is at y=16 (except Stimmewlants which is special)
var potion_offsets = {
	2: 32,   # Regen
	3: 16,   # Alakitty
	4: 0,    # Spiwits
	5: 48,   # Stimmewlants (special case - both at y=32)
	6: 48,   # Swiftnuss
}

# Potion ID -> fluid color
var potion_colors = {
	2: Color(1.5, 0.6, 1.0, 1.0),    # Regen - bright pink
	3: Color(0.7, 1.5, 0.5, 1.0),    # Alakitty - lime green
	4: Color(0.8, 0.55, 0.35, 1.0),  # Spiwits - murky brown
	5: Color(1.5, 1.5, 0.5, 1.0),    # Stimmewlants - star yellow
	6: Color(1.0, 0.75, 1.3, 1.0),   # Swiftnuss - soft purple
}

@export var potionID:int

@export var potionsprites:Array[Sprite2D]

func _ready():
	# Set the items texture on all sprites and reset modulate from black to white
	for sprite in potionsprites:
		sprite.texture = ITEMS_TEXTURE
		sprite.modulate = Color.WHITE
		sprite.self_modulate = Color.WHITE
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 16, 16)

func _process(delta: float) -> void:
	if not potion_offsets.has(potionID):
		return
	
	var x_offset = potion_offsets[potionID]
	var fluid_color = potion_colors.get(potionID, Color.WHITE)
	
	for sprite in potionsprites:
		# Stimmewlants (ID 5) is a special case - uses y=32 for both
		if potionID == 5:
			if sprite.name == "Out":
				sprite.region_rect = Rect2(x_offset, 32, 16, 16)
				sprite.modulate = Color.WHITE
				sprite.self_modulate = Color.WHITE
			else:
				sprite.region_rect = Rect2(32, 32, 16, 16)  # fluid at different x
				sprite.modulate = fluid_color
				sprite.self_modulate = fluid_color
		else:
			# Normal potions: Out = bottle (y=0), Out2 = fluid (y=16)
			if sprite.name == "Out":
				sprite.region_rect = Rect2(x_offset, 0, 16, 16)
				sprite.modulate = Color.WHITE
				sprite.self_modulate = Color.WHITE
			else:
				sprite.region_rect = Rect2(x_offset, 16, 16, 16)
				sprite.modulate = fluid_color
				sprite.self_modulate = fluid_color
		
			
	
