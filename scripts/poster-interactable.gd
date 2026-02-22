extends Workstation

# Called when the player actually triggers the interaction
@onready var pop_up:Sprite2D = $Popup

# Called when the server registers the player starting to use this workstation
func start_use(peer_id:int):
	print("[Poster] start_use() for peer: ", peer_id)
	show_popup.rpc_id(peer_id)

# Called when the server registers the player ending use
func end_use(peer_id:int):
	print("[Poster] end_use() for peer: ", peer_id)
	hide_popup.rpc_id(peer_id)

@rpc("any_peer", "call_local")
func show_popup():
	pop_up.visible = true

@rpc("any_peer", "call_local")
func hide_popup():
	pop_up.visible = false
