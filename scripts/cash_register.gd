extends Workstation
class_name cash_register

@onready var popup:Sprite2D = $Sprite2D
@export var customers: customerline
var current_order = null



# Called when the player actually triggers the interaction
@rpc('any_peer','call_local')
func interact(player):
	print("[CashRegister] interacted with!")
	#extremely bandaid fix
	if(player == 0):
		player = 1
	
	
	if customers.front == null:
		print("You have no customers!!!")
		return
	
	if(current_order == null):
		current_order = randi_range(2,6)
	
	print("Player:" + str(player))
	#access player
	
	var playerNode:player_movement = get_tree().get_root().get_node("Node3D/"+str(player))
	var held:Item = playerNode.holding_something
	if(held != null):
		if(held.Id == current_order):
			playerNode.take_hand()
			#ADD MONEy
			customers.destroy_front()
			current_order = null
			return;
	popup.visible = true
			
		
		
	
	# Here you could open a UI for the player

# Called when the server registers the player starting to use this workstation
func start_use(peer_id:int):
	print("[CashRegister] start_use() for peer: ", peer_id)
	print("[CashRegister] Player is now actively using the cauldron.")
	interact(peer_id)
# Called when the server registers the player ending use
func end_use(peer_id:int):
	print("[CashRegister] end_use() for peer: ", peer_id)
	print("[CashRegister] Player has stopped using the cauldron.")
	popup.visible = false
	
