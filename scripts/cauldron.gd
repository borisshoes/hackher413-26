extends Workstation

@onready var cauldron_ui_scene = preload("res://scenes/cauldron_ui_holder.tscn")

var current_brew: Array = [] # authoritative on server
var ui_instances := {} # map of player node -> UI Control

# Grown plant IDs (seed_id + 100): 150=Lavender, 151=Lily, 152=Mandrake, 153=Mint
var accepted_ids = [150, 151, 152, 153]

# Map plant ID to ingredient name for brewing
func _get_ingredient_name(item_id: int) -> String:
	match item_id:
		150: return "A"  # Lavender
		151: return "B"  # Lily
		152: return "C"  # Mandrake
		153: return "D"  # Mint
		_: return ""

# -------------------------
# Override start_use - this is where ingredients get added
# -------------------------
const MAX_INGREDIENTS = 8

func start_use(peer_id: int):
	print("[Cauldron] start_use called on %s, is_server: %s" % [name, multiplayer.is_server()])
	
	# Don't accept more than 8 ingredients
	if current_brew.size() >= MAX_INGREDIENTS:
		print("[Cauldron] Already full, cannot add more ingredients")
		return
	
	var player = _get_player_from_peer(peer_id)
	if player == null:
		print("[Cauldron] Player not found for peer %d" % peer_id)
		return
	
	if not player.holding_something:
		print("Player empty-handed")
		return
	
	var item_id = int(player.holding_something.Id)
	if item_id not in accepted_ids:
		print("Cauldron doesn't accept this item (ID: %d)" % item_id)
		return
	
	var ingredient_name = _get_ingredient_name(item_id)
	current_brew.append(ingredient_name)
	print("[Server] Added ingredient %s (%d/%d), current_brew is now: %s" % [ingredient_name, current_brew.size(), MAX_INGREDIENTS, current_brew])
	player.take_hand()
	
	# Sync to all clients
	sync_current_brew.rpc(current_brew)
	
	# Check if cauldron is full
	if current_brew.size() >= MAX_INGREDIENTS:
		var recipe = BrewDatabase.match_recipe(current_brew)
		if recipe != null:
			print("[Server] Recipe matched: %s" % recipe.recipe_name)
			complete_brew(recipe)
		else:
			print("[Server] No matching recipe found!")
			# Clear the cauldron anyway
			current_brew.clear()
			sync_current_brew.rpc(current_brew)

# -------------------------
# SERVER: Complete brew
# -------------------------
func complete_brew(recipe: Recipe):
	print("[Server] Brew completed: %s" % recipe.recipe_name)
	current_brew.clear()
	sync_current_brew.rpc(current_brew)

# -------------------------
# CLIENT: Sync current brew
# -------------------------
@rpc("call_local")
func sync_current_brew(new_brew:Array):
	print("[Cauldron %s] sync_current_brew called with: %s" % [name, new_brew])
	current_brew = new_brew.duplicate()
	print("[Cauldron %s] current_brew after assignment: %s" % [name, current_brew])
	print("[Cauldron %s] ui_instances count: %d" % [name, ui_instances.size()])
	for player in ui_instances.keys():
		var sprite3d = ui_instances[player]
		print("[Cauldron %s] Updating UI for player, sprite3d valid: %s" % [name, is_instance_valid(sprite3d)])
		if is_instance_valid(sprite3d):
			var control = sprite3d.get_node("SubViewport/CauldronUI")
			print("[Cauldron %s] Control found: %s, passing: %s" % [name, control != null, current_brew])
			control.update_progress(current_brew)

# -------------------------
# PLAYER ENTER/EXIT
# -------------------------
func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	if body.is_multiplayer_authority():
		nearby_players[body] = true
		show_label()
		_spawn_ui_for_player(body)
		body.set_active_workstation(self)

func _on_body_exited(body):
	if not body.is_in_group("player"):
		return
	
	if not body.is_multiplayer_authority():
		return

	nearby_players.erase(body)
	hide_label()
	_despawn_ui_for_player(body)
	body.clear_active_workstation(self)

# -------------------------
# SPAWN / DESPAWN UI
# -------------------------
@export var ui_offset: Vector3 = Vector3(0, 1, 0)

func _spawn_ui_for_player(player):
	if ui_instances.has(player):
		return

	var ui = cauldron_ui_scene.instantiate()
	add_child(ui)
	ui.position = ui_offset
	ui_instances[player] = ui
	# Navigate to Control inside Sprite3D > SubViewport > Control
	# Defer the update so _ready runs first
	var control = ui.get_node("SubViewport/CauldronUI")
	control.call_deferred("update_progress", current_brew)

func _despawn_ui_for_player(player):
	if ui_instances.has(player):
		var ui = ui_instances[player]
		if is_instance_valid(ui):
			ui.queue_free()
		ui_instances.erase(player)
