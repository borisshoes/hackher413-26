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
@export var instant_interact:bool = false

var label: Label3D  # Set in _ready or by subclass
var area  # Set in _ready or by subclass
var sprite  # Set in _ready or by subclass
var interaction_shape: CollisionShape3D  # Set in _ready or by subclass
var collision_shape: CollisionShape3D  # Set in _ready or by subclass

var nearby_players := {}
var active_users: Array[int] = []

func _ready():
	add_to_group("workstation")
	
	# Only set these if subclass hasn't already
	if label == null:
		label = get_node_or_null("InteractionLabel")
	if area == null:
		area = get_node_or_null("InteractionArea")
	if sprite == null:
		sprite = get_node_or_null("Visual")
	if interaction_shape == null:
		interaction_shape = get_node_or_null("InteractionArea/CollisionShape3D")
	if collision_shape == null:
		collision_shape = get_node_or_null("CollisionArea/CollisionShape3D")
	
	if sprite:
		sprite.texture = sprite_texture
		sprite.region_enabled = true
		sprite.region_rect = atlas_region

	_apply_sizes()
	
	if label:
		label.text = interaction_text
		label.position = label_offset
		label.visible = false

	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _apply_sizes():
	if interaction_shape:
		var i_shape = interaction_shape.shape as BoxShape3D
		if i_shape:
			i_shape.size = Vector3(interaction_size, interaction_size, interaction_size)

	if collision_shape:
		var c_shape = collision_shape.shape as BoxShape3D
		if c_shape:
			c_shape.size = Vector3(collision_size, collision_size, collision_size)

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
	if !body.is_in_group("player"):
		return
	
	if !body.is_multiplayer_authority():
		return

	nearby_players.erase(body)
	hide_label()
	body.clear_active_workstation(self)

	# tell server player stopped using
	end_use_request.rpc_id(1)
		
func show_label():
	if not label:
		return
	label.visible = true
	label.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(label, "modulate:a", 1.0, 0.15)

func hide_label():
	if not label:
		return
	var t = create_tween()
	t.tween_property(label, "modulate:a", 0.0, 0.15)
	t.tween_callback(func(): label.visible = false)

@rpc("any_peer")
func request_use(caller_peer_id: int = 0):
	if !multiplayer.is_server():
		return

	# Get peer_id from RPC sender, or use passed value for local server calls
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = caller_peer_id
	
	print("[Workstation] request_use called, peer_id: %d, instant_interact: %s" % [peer_id, instant_interact])

	# Instant interactions skip active_users tracking entirely
	if instant_interact:
		print("[Workstation] Calling start_use for peer %d" % peer_id)
		start_use(peer_id)
		emit_signal("use_started", peer_id)
		end_use(peer_id)
		emit_signal("use_ended", peer_id)
		return

	if !allow_multiple_interacts and active_users.size() > 0:
		print("[Workstation] Rejected - already in use")
		return

	if peer_id in active_users:
		print("[Workstation] Rejected - peer already active")
		return

	active_users.append(peer_id)

	sync_active_users.rpc(active_users)
	print("[Workstation] Calling start_use for peer %d" % peer_id)
	start_use(peer_id)
	emit_signal("use_started", peer_id)


@rpc("any_peer", "call_local")
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

# Helper to get player node from peer_id
func _get_player_from_peer(peer_id: int) -> Node:
	return get_tree().current_scene.get_node_or_null(str(peer_id))

# Override in subclass to handle interaction
func start_use(peer_id: int):
	pass

func end_use(peer_id: int):
	pass
