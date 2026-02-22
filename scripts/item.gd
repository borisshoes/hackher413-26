extends Node3D
class_name Item


@export var Id: int
@export var XOffset: int
@export var YOffset: int
@export var colorMod: Color
@export var Sprite := "res://assets/sprites/items.png"


#Used by server
@export var player_holding = null

#Used by local
var in_range = false



@onready var collision = $StaticBody3D/CollisionShape3D
@onready var label = $Label3D
@onready var tex = $StaticBody3D/Sprite3D
var local_player = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tex.texture = load(Sprite)
	tex.region_rect = Rect2(Vector2(XOffset, YOffset), Vector2(16, 16))
	tex.modulate = colorMod
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	local_player = NetHandler.local_player
	if Input.is_action_just_pressed("pickup"):
		
		if local_player.holding_something == null && in_range:
			pickup.rpc(int(local_player.name))
			label.text ="Place (E)"
			local_player.holding_something = self
		elif local_player.holding_something == self:
			place.rpc(int(local_player.name))
			label.text ="Pick Up (E)"
			local_player.holding_something = null
	
	if !multiplayer.is_server(): return
	
	if player_holding != null:
		position = player_holding.position + Vector3(0,2, 0)
		
		
	pass
	
#Function for picking up
@rpc("any_peer", "call_local") 
func pickup(player: int) -> void:
	if !multiplayer.is_server(): return
	if player_holding == null:
		collision.disabled = true
		player_holding = get_tree().current_scene.get_node(str(player))
		player_holding.holding_something = self
#Function for putting down
@rpc("any_peer", "call_local") func place(player: int) -> void:
	if !multiplayer.is_server(): return
	
	if player_holding != null:
		player_holding.holding_something = null
	player_holding = null
	
	collision.disabled = false
	position -= Vector3(0,.5,-.25)



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
