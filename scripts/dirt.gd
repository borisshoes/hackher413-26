
extends Workstation

@export var planted := false
@export var progress := 0
@export var planted_id = -1
@export var total := 1200
@export var plant_array: Array[PackedScene] = []

var accepted_ids = [50, 51, 52, 53]

signal pressed_signal

@export var interaction_radius:float = 1.5
@export var press_depth := 0.1
@export var press_time := 0.1

@onready var stage1 = $CollisionArea/Planted
@onready var stage2 = $CollisionArea/Grown

@onready var progress_bar_texture = $CollisionArea/ProgressBar
@onready var progress_bar = $CollisionArea/ProgressBar/SubViewport/ProgressBar



@onready var location_1 = $Location1
@onready var location_2 = $Location2



func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	if planted and progress < total:
		progress += 1
	
	if progress >= total:
		var item = null
		var second_item = null
		for packed_plant in plant_array:
			var plant = packed_plant.instantiate()
			if plant.Id == planted_id:
				item = plant
			elif plant.Id == planted_id + 100:
				second_item = plant
			else:
				plant.queue_free()
		var new_seed = item
		var new_plant = second_item
		
		new_seed.position = location_1.global_position
		new_plant.position = location_2.global_position
		NetHandler.spawner.get_parent().call_deferred("add_child", new_seed, true)
		NetHandler.spawner.get_parent().call_deferred("add_child", new_plant, true)
		
		planted = false
		progress = 0
		
		
func _process(delta: float) -> void:
	if planted:
		progress_bar_texture.visible = true
		progress_bar.value = (float(progress)/float(total)) * progress_bar.max_value
		if progress_bar.value < 50:
			stage1.visible = true
			stage2.visible = false
		elif progress_bar.value > 50:
			stage1.visible = false
			stage2.visible = true
	else:
		stage1.visible = false
		stage2.visible = false
		progress_bar_texture.visible = false

func _ready():
	# Set node paths before base class _ready runs
	sprite = $CollisionArea/Visual
	label = $InteractionLabel
	# Don't set area - scene already has signals connected to _on_area_3d_body_entered/exited
	super._ready()

# Don't let base class resize our collision shapes - they're set in the scene
func _apply_sizes():
	pass

# Scene has signals connected to these names - forward to inherited methods
func _on_area_3d_body_entered(body):
	_on_body_entered(body)

func _on_area_3d_body_exited(body):
	_on_body_exited(body)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	if body.is_multiplayer_authority():
		nearby_players[body] = true
		show_label()
		body.set_active_workstation(self)

func _on_body_exited(body):
	if not body.is_in_group("player"):
		return
	
	if not body.is_multiplayer_authority():
		return
	
	nearby_players.erase(body)
	hide_label()
	body.clear_active_workstation(self)

# Override start_use - this is where the planting happens
func start_use(peer_id: int):
	print("[Dirt] start_use called, peer_id: %d, planted: %s" % [peer_id, planted])
	if planted:
		print("[Dirt] Already planted, returning")
		return
	var player = _get_player_from_peer(peer_id)
	if player == null:
		print("[Dirt] Player not found for peer %d" % peer_id)
		return
	var holding = player.holding_something
	if holding == null:
		print("[Dirt] Player not holding anything")
		return
	var id_held = int(holding.Id)
	print("[Dirt] Player holding item with Id: %d, accepted: %s" % [id_held, accepted_ids])
	if id_held in accepted_ids:
		print("[Dirt] Planting!")
		planted = true
		planted_id = id_held
		progress = 0
		player.take_hand()
