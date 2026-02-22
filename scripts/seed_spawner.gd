extends Node3D
@onready var s1 =$"1"
@onready var s2 =$"2"
@onready var s3 =$"3"
@onready var s4=$"4"

@export var seed1: PackedScene
@export var seed2: PackedScene
@export var seed3: PackedScene
@export var seed4: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !multiplayer.is_server(): return
	var seed_1_instance = seed1.instantiate()
	seed_1_instance.position = s1.global_position
	
	var seed_2_instance = seed2.instantiate()
	seed_2_instance.position = s2.global_position
	
	var seed_3_instance = seed3.instantiate()
	seed_3_instance.position = s3.global_position
	
	var seed_4_instance = seed4.instantiate()
	seed_4_instance.position = s4.global_position
	
	NetHandler.spawner.get_parent().call_deferred("add_child", seed_1_instance, true)
	NetHandler.spawner.get_parent().call_deferred("add_child", seed_2_instance, true)
	NetHandler.spawner.get_parent().call_deferred("add_child", seed_3_instance, true)
	NetHandler.spawner.get_parent().call_deferred("add_child", seed_4_instance, true)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
