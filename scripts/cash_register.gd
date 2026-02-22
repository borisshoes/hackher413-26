extends Workstation

@onready var popup:Sprite2D = $OrderSlip
@onready var potion_display = $OrderSlip/PotionSihlouette
@export var customers: customerline
@export var current_order: int = -1



# Called when the player actually triggers the interaction
@rpc('any_peer','call_local')
func interact(player):
	var player_interacted = get_tree().current_scene.get_node_or_null(str(player))
	print("[CashRegister] interacted with!")
	#extremely bandaid fix

	
	
	if customers.front == null:
		print("You have no customers!!!")
		return
	
	if(current_order == -1):
		current_order = randi_range(2,6)
		if potion_display:
			potion_display.potionID = current_order
		# Sync the order display to all clients
		sync_order_display.rpc(current_order)
	
	print("Player:" + str(player))
	#access player
	
	
	var held:Node = player_interacted.holding_something
	if(held != null):
		if(held.Id == current_order):
			player_interacted.take_hand()
			$"../UI".add_cash.rpc_id(1, 20)
			customers.destroy_front()
			current_order = -1
			return;

			
		
		
	
	# Here you could open a UI for the player

# Called when the server registers the player starting to use this workstation
var local_held_id



func start_use(peer_id:int):
	NetHandler.local_player.send_local_id.rpc(1, peer_id, true)
	local_held_id = NetHandler.local_player.held_id
	
	# Check if we should show the popup
	if current_order >= 2 and current_order <= 6:
		if local_held_id == -1 or local_held_id != current_order:
			show_popup.rpc_id(peer_id)
	else:
		# Invalid order - release the user immediately
		print("[CashRegister] No valid order, releasing user")
		_release_user(peer_id)
		return
	
	print("[CashRegister] start_use() for peer: ", peer_id)
	interact.rpc_id(1, peer_id)

func _release_user(peer_id: int):
	# Remove from active_users and sync
	if peer_id in active_users:
		active_users.erase(peer_id)
		sync_active_users.rpc(active_users)
		end_use(peer_id)
		emit_signal("use_ended", peer_id)
# Called when the server registers the player ending use
func end_use(peer_id:int):
	print(peer_id)
	print("[CashRegister] end_use() for peer: ", peer_id)
	print("[CashRegister] Player has stopped using the cauldron.")
	# Hide popup on the specific client
	hide_popup.rpc_id(peer_id)

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
	if potion_display:
		potion_display.potionID = item_id
	
