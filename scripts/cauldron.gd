extends Workstation

# Called when the player actually triggers the interaction
func interact(player):
	print("[Cauldron] interact() called by player: ", player.name)
	print("[Cauldron] Opening brewing UI...")
	# Here you could open a UI for the player

# Called when the server registers the player starting to use this workstation
func start_use(peer_id:int):
	print("[Cauldron] start_use() for peer: ", peer_id)
	print("[Cauldron] Player is now actively using the cauldron.")

# Called when the server registers the player ending use
func end_use(peer_id:int):
	print("[Cauldron] end_use() for peer: ", peer_id)
	print("[Cauldron] Player has stopped using the cauldron.")
