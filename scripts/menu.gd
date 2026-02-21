extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@export var Handler: PackedScene
@export var Map: PackedScene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_client_pressed() -> void:
	NetHandler.start_client()
	var map: Node = Map.instantiate()
	var HandlerInstance: Node = Handler.instantiate()
	
	$"..".call_deferred("add_child", HandlerInstance)
	$"..".call_deferred("add_child", map)
	delete()
	
func _on_server_pressed() -> void:
	NetHandler.start_server()
	var map: Node = Map.instantiate()
	var HandlerInstance: Node = Handler.instantiate()
	$"..".call_deferred("add_child", HandlerInstance)
	$"..".call_deferred("add_child", map)
	delete()

func delete() -> void:
	queue_free()
	
