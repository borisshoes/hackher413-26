extends Node3D

signal pressed_signal

@export var interaction_text:String = "Interact (F)"
@export var interaction_radius:float = 1.5
@export var sprite_texture:Texture2D
@export var atlas_region:Rect2i = Rect2i(0, 0, 32, 32)
@export var press_depth := 0.1
@export var press_time := 0.1

@onready var area = $InteractionArea
@onready var sprite = $Visual

var nearby_players := {}

func _ready():
	sprite.texture = sprite_texture
	sprite.region_enabled = true
	sprite.region_rect = atlas_region

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if not body.is_in_group("players"):
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

func interact(player):
	# virtual function
	print("Generic workstation used")
	
func show_tooltip(player):
	var tooltip = preload("res://scenes/tooltip.tscn").instantiate()
	tooltip.target = $TooltipAnchor
	tooltip.get_node("Label").text = interaction_text
	player.add_child(tooltip)

func hide_tooltip(player):
	for child in player.get_children():
		if child.name == "Tooltip":
			child.queue_free()
