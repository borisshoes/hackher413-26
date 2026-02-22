extends Node3D

@export var bottle_slot: PackedScene = null
var active_bottle: Node = null


	
func _process(delta: float) -> void:
	if !multiplayer.is_server(): return
	
	if active_bottle == null:
		var new_potion = bottle_slot.instantiate()
		new_potion.position = global_position
		active_bottle = new_potion
		print("spawned")
		NetHandler.spawner.get_parent().call_deferred("add_child", new_potion, true)
	else:
		if active_bottle.player_holding != null:
			active_bottle = null
	#if bottle_slot == null:
		
