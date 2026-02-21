extends MultiplayerSpawner

@export var network_player: PackedScene

func _ready() -> void:

	spawn_player(1)
	multiplayer.peer_connected.connect(spawn_player)
	
	
func spawn_player(id: int) -> void:
	#Only the server can spawn players
	if !multiplayer.is_server(): return
	var player: Node = network_player.instantiate()
	player.name = str(id)
	if id == 1:
		NetHandler.local_player = player
	get_node(spawn_path).call_deferred("add_child", player)
	


func _on_spawned(node: Node) -> void:
	print("Hi!")
	if node.name == str(multiplayer.get_unique_id()):
		NetHandler.local_player = node
