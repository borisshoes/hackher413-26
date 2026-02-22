extends Node2D

@export var money: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@rpc("any_peer", "call_local")
func add_cash(amount: int) -> void:
	if !multiplayer.is_server(): return
	$Coins.realNum += amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
