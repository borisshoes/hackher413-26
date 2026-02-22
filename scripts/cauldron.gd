extends Workstation

@onready var cauldron_ui_scene = preload("res://scenes/cauldron_ui.tscn")

var current_brew: Array = [] # authoritative on server
var ui_instances := {} # map of player node -> UI Control

# -------------------------
# PLAYER INTERACT
# -------------------------
func interact(player):
	if not player.holding_something:
		print("Player empty-handed")
		return

	# Only server modifies the brew
	if not multiplayer.is_server():
		# send RPC to server
		rpc_id(1, "_server_add_ingredient", player.get_multiplayer_authority(), player.holding_something.name)
		player.holding_something = null
		return

	_server_add_ingredient(player.get_multiplayer_authority(), player.holding_something.name)
	player.holding_something = null

# -------------------------
# SERVER: Add ingredient
# -------------------------
@rpc("any_peer")
func _server_add_ingredient(peer_id:int, ingredient_name:String):
	if !(peer_id in active_users):
		return # only active users can add

	current_brew.append(ingredient_name)
	print("[Server] Added ingredient %s from peer %d" % [ingredient_name, peer_id])

	# Sync to all clients
	sync_current_brew.rpc(current_brew)

	# Check if any recipe completed
	var recipe = BrewDatabase.match_recipe(current_brew)
	if recipe.size() > 0 and current_brew.size() == recipe["ingredients"].size():
		complete_brew(recipe)

# -------------------------
# SERVER: Complete brew
# -------------------------
func complete_brew(recipe:Dictionary):
	print("[Server] Brew completed: %s" % recipe["name"])
	current_brew.clear()
	sync_current_brew.rpc(current_brew)

# -------------------------
# CLIENT: Sync current brew
# -------------------------
@rpc("call_local")
func sync_current_brew(new_brew:Array):
	current_brew = new_brew
	for player in ui_instances.keys():
		var ui = ui_instances[player]
		if is_instance_valid(ui):
			ui.update_progress(current_brew)

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
	if not body.is_multiplayer_authority():
		return

	nearby_players.erase(body)
	hide_label()
	_despawn_ui_for_player(body)
	body.clear_active_workstation(self)

	if active_users.has(body):
		end_use(body)

# -------------------------
# SPAWN / DESPAWN UI
# -------------------------
func _spawn_ui_for_player(player):
	if ui_instances.has(player):
		return

	var ui = cauldron_ui_scene.instantiate()
	player.add_child(ui)
	# Control nodes use Vector2, positioned via anchors/layout_mode
	ui.update_progress(current_brew) # initial sync
	ui_instances[player] = ui

func _despawn_ui_for_player(player):
	if ui_instances.has(player):
		var ui = ui_instances[player]
		if is_instance_valid(ui):
			ui.queue_free()
		ui_instances.erase(player)
