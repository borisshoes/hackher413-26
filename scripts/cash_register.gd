extends Workstation

@onready var popup:Sprite2D = $OrderSlip
@onready var potion_display = $OrderSlip/PotionSihlouette
@export var customers: customerline
@export var current_order: int = -1

func _ready():
	# Cash register uses instant_interact so users never get locked
	instant_interact = true
	super._ready()



# Called when the player actually triggers the interaction
@rpc('any_peer','call_local')
func interact(player):
	# Only server handles interaction logic
	if !multiplayer.is_server():
		return
		
	var player_interacted = get_tree().current_scene.get_node_or_null(str(player))
	if player_interacted == null:
		return
	
	if customers.front == null:
		return
	
	var held:Node = player_interacted.holding_something
	if held != null and held.Id == current_order:
		player_interacted.take_hand()
		$"../UI".add_cash.rpc_id(1, 20)
		customers.destroy_front()
		# Reset and sync the order to all clients
		sync_order_display.rpc(-1)

# Called when the server registers the player starting to use this workstation
func start_use(peer_id:int):
	# Check if there's a customer and set order if needed
	if customers.front != null and current_order == -1:
		current_order = randi_range(2,6)
		if potion_display:
			potion_display.potionID = current_order
		sync_order_display.rpc(current_order)
	
	# Show popup and try to interact if there's a valid order
	if current_order >= 2 and current_order <= 6:
		show_popup.rpc_id(peer_id)
		interact.rpc_id(1, peer_id)

func _release_user(peer_id: int):
	# Remove from active_users and sync
	if peer_id in active_users:
		active_users.erase(peer_id)
		sync_active_users.rpc(active_users)
		emit_signal("use_ended", peer_id)

# Called when the server registers the player ending use
# With instant_interact, this is called immediately - don't hide popup here
func end_use(peer_id:int):
	pass

# Hide popup when player walks away
func _on_body_exited(body):
	super._on_body_exited(body)
	if body.is_in_group("player") and body.is_multiplayer_authority():
		popup.visible = false

@rpc("any_peer", "call_local")
func show_popup():
	# Only show popup if current_order is a valid potion ID (2-6)
	if current_order < 2 or current_order > 6:
		print("[CashRegister] Cannot show popup - invalid potion ID: %d" % current_order)
		return
	print("[CashRegister] Showing order slip, current_order potion ID: %d" % current_order)
	popup.visible = true

@rpc("any_peer", "call_local")
func hide_popup():
	popup.visible = false

@rpc("any_peer", "call_local")
func sync_order_display(item_id: int):
	current_order = item_id
	if potion_display:
		potion_display.potionID = item_id
	
