extends Control

@export var ingredient_textures: Array[Texture2D] = []
# 0-A = Lavender, 1-B = Lily, 2-C = Mandrake, 3-D = Mint 

var slots: Array[TextureRect] = []

func _ready():
	# Collect all slots from HBoxContainer
	slots.clear()
	for i in range(8):
		var slot = $HBoxContainer.get_child(i)
		slots.append(slot)
		slot.texture = null # empty by default
	print("[CauldronUI] _ready complete, slots: %d" % slots.size())

# Called from workstation when brew state updates
func update_progress(current_brew: Array):
	print("[CauldronUI] update_progress called with: %s" % [current_brew])
	print("[CauldronUI] slots count: %d, textures count: %d" % [slots.size(), ingredient_textures.size()])
	# Clear all slots first
	for slot in slots:
		slot.texture = null

	# Fill slots with blobs corresponding to ingredients
	for i in range(current_brew.size()):
		var ingredient_name = current_brew[i]
		var blob_texture = _get_blob_for_ingredient(ingredient_name)
		print("[CauldronUI] Slot %d: ingredient=%s, texture=%s" % [i, ingredient_name, blob_texture])
		if blob_texture and i < slots.size():
			slots[i].texture = blob_texture

# Map ingredient IDs to textures
func _get_blob_for_ingredient(ingredient_name: String) -> Texture2D:
	match ingredient_name:
		"A":
			return ingredient_textures[0]
		"B":
			return ingredient_textures[1]
		"C":
			return ingredient_textures[2]
		"D":
			return ingredient_textures[3]
		_:
			return null
