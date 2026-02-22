
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
	sprite = $CollisionArea/Visual
	add_to_group("workstation")
	
	sprite.texture = sprite_texture
	sprite.region_enabled = true
	sprite.region_rect = atlas_region

	#_apply_sizes()
	
	label.text = interaction_text
	label.position = label_offset
	label.visible = false

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	
	if not body.is_in_group("player"):
		return
	
	if body.is_multiplayer_authority():
		nearby_players[body] = true
		#show_tooltip(body)

func _on_body_exited(body):
	if nearby_players.has(body):
		nearby_players.erase(body)
		#hide_tooltip(body)

func try_interact(player):
	if not player.is_multiplayer_authority():
		return

	interact(player)
	
@rpc("any_peer","call_local")
func server_planter_function(id: int) -> void:
	if planted: return
	if !multiplayer.is_server(): return
	var player = get_tree().current_scene.get_node(str(id))
	if player == null: return
	var holding = player.holding_something
	if holding == null: return
	var id_held = int(holding.Id)
	if id_held in accepted_ids:
		planted = true
		planted_id = id_held
		progress = 0
		player.take_hand()

func interact(player):
	print("PLANTING TIME")
	server_planter_function.rpc_id(1, int(player.name))
	# virtual function
	
	
#func show_tooltip(player):
	#var tooltip = preload("res://scenes/tooltip.tscn").instantiate()
	#tooltip.target = $TooltipAnchor
	#tooltip.get_node("Label").text = interaction_text
	#player.add_child(tooltip)

func hide_tooltip(player):
	for child in player.get_children():
		if child.name == "Tooltip":
			child.queue_free()
