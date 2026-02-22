extends Node3D

const SPEED = 5
@export var target: Vector3
@export var slot := 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func move_to(position: Vector3) -> void:
	target = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !multiplayer.is_server(): return
	position = position.move_toward(target, SPEED * delta)
