extends Node

const ADDRESS = "localhost"
const PORT = 3621

@export var local_player: Node = null
@export var spawner: Node = null

var peer: ENetMultiplayerPeer


	
	
	


func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	
func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
