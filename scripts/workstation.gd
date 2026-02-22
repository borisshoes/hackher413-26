extends Node3D
class_name Workstation

signal use_started(peer_id)
signal use_ended(peer_id)

@export var sprite_texture:Texture2D
@export var atlas_region:Rect2i = Rect2i(0, 0, 32, 32)
@export var label_offset: Vector3 = Vector3(0, 1.5, 0)
@export var interaction_text:String = "Interact (F)"
@export var interaction_size:float = 1.0
@export var collision_size:float = 0.5
@export var allow_multiple_interacts:bool = false

@onready var label: Label3D = $InteractionLabel
@onready var area = $InteractionArea
@onready var sprite = $Visual
@onready var interaction_shape: CollisionShape3D = $InteractionArea/CollisionShape3D
@onready var collision_shape: CollisionShape3D = $CollisionArea/CollisionShape3D

var nearby_players := {}
var active_users: Array[int] = []

func _ready():
	add_to_group("workstation")
	
	sprite.texture = sprite_texture
	sprite.region_enabled = true
	sprite.region_rect = atlas_region

	_apply_sizes()
	
	label.text = interaction_text
	label.position = label_offset
	label.visible = false

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _apply_sizes():
	var i_shape = interaction_shape.shape as BoxShape3D
	if i_shape:
		i_shape.size = Vector3(interaction_size, interaction_size, interaction_size)

	var c_shape = collision_shape.shape as BoxShape3D
	if c_shape:
		c_shape.size = Vector3(collision_size, collision_size, collision_size)

func _on_body_entered(body):
	if !body.is_in_group("player"):
		return

	if body.is_multiplayer_authority():
		nearby_players[body] = true
		show_label()
		body.set_active_workstation(self)


func _on_body_exited(body):
	if !body.is_multiplayer_authority():
		return

	nearby_players.erase(body)
	hide_label()
	body.clear_active_workstation(self)

	# tell server player stopped using
	end_use_request.rpc_id(1)
		
func show_label():
	label.visible = true
	label.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(label, "modulate:a", 1.0, 0.15)

func hide_label():
	var t = create_tween()
	t.tween_property(label, "modulate:a", 0.0, 0.15)
	t.tween_callback(func(): label.visible = false)

@rpc("any_peer")
func request_use():
	if !multiplayer.is_server():
		return

	var peer_id = multiplayer.get_remote_sender_id()

	if !allow_multiple_interacts and active_users.size() > 0:
		return

	if peer_id in active_users:
		return

	active_users.append(peer_id)

	sync_active_users.rpc(active_users)
	start_use(peer_id)
	emit_signal("use_started", peer_id)


@rpc("any_peer")
func end_use_request():
	if !multiplayer.is_server():
		return

	var peer_id = multiplayer.get_remote_sender_id()

	if peer_id in active_users:
		active_users.erase(peer_id)

		sync_active_users.rpc(active_users)
		end_use(peer_id)
		emit_signal("use_ended", peer_id)


@rpc("call_local")
func sync_active_users(new_users:Array):
	active_users = new_users

func is_in_use() -> bool:
	return active_users.size() > 0
	
func start_use(peer_id:int):
	print("Using Generic Workstation")
	pass

func end_use(peer_id:int):
	print("Leaving Generic Workstation")
	pass
