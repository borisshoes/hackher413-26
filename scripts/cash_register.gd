extends Workstation

@onready var popup:Sprite2D = $OrderSlip
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
	
	print("Player:" + str(player))
	#access player
	
	
	var held:Node = player_interacted.holding_something
	if(held != null):
		if(held.Id == current_order):
			player_interacted.take_hand()
			#ADD MONEy
			customers.destroy_front()
			current_order = -1
			return;

			
		
		
	
	# Here you could open a UI for the player

# Called when the server registers the player starting to use this workstation
var local_held_id



func start_use(peer_id:int):

	NetHandler.local_player.send_local_id.rpc(1, peer_id, true)
	local_held_id = NetHandler.local_player.held_id
	if local_held_id == -1 or local_held_id != current_order:
			popup.visible = true
	print("[CashRegister] start_use() for peer: ", peer_id)
	print("[CashRegister] Player is now actively using the cauldron.")
	interact.rpc_id(1, peer_id)
# Called when the server registers the player ending use
func end_use(peer_id:int):
	print(peer_id)
	print("[CashRegister] end_use() for peer: ", peer_id)
	print("[CashRegister] Player has stopped using the cauldron.")
	popup.visible = false
	
