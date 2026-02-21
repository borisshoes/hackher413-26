extends Node3D

#Used by server
var player_holding = null

#Used by local
var in_range = false



@onready var collision = $StaticBody3D/CollisionShape3D
@onready var label = $Label3D
var local_player = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	while local_player == null:
		local_player = NetHandler.local_player
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pickup"):
		
		if local_player.holding_something == null && in_range:
			pickup.rpc(int(local_player.name))
			local_player.holding_something = self
		elif local_player.holding_something == self:
			place.rpc(int(local_player.name))
			local_player.holding_something = null
	
	if !multiplayer.is_server(): return
	
	if player_holding != null:
		position = player_holding.position + Vector3(0,2,1)
		
		
	pass
	
#Function for picking up
@rpc("any_peer", "call_local") func pickup(player: int) -> void:
	if !multiplayer.is_server(): return
	if player_holding == null:
		collision.disabled = true
		player_holding = get_tree().current_scene.get_node(str(player))

#Function for putting down
@rpc("any_peer", "call_local") func place(player: int) -> void:
	if !multiplayer.is_server(): return
	player_holding = null
	collision.disabled = false
	position -= Vector3(0,1,1)



func _on_area_3d_body_entered(body: Node3D) -> void:
	if local_player != null:
		if (body.name == local_player.name):
			if collision.disabled == false and local_player.holding_something == null:
				in_range = true
				label.text = "Pick Up (E)"
			pass


func _on_area_3d_body_exited(body: Node3D) -> void:
	if local_player != null:
		if (body.name == local_player.name):
			in_range = false
			label.text = ""
			pass
