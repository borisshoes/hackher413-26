extends Workstation

# Called when the player actually triggers the interaction
@onready var pop_up:Sprite2D = $Popup

# Called when the server registers the player starting to use this workstation
func start_use(peer_id:int):
	print("[CashRegister] start_use() for peer: ", peer_id)
	print("[CashRegister] Player is now actively using the poster.")
	pop_up.visible = true
# Called when the server registers the player ending use
func end_use(peer_id:int):
	print("[CashRegister] end_use() for peer: ", peer_id)
	print("[CashRegister] Player has stopped using the poster.")
	pop_up.visible = false
