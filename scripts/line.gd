extends Node3D
class_name customerline

@export var front: Node = null
@export var customer: PackedScene


var time = 60 * 16
var spawntime = 60 * 25


var slots = [false, false, false, false, false]
var customers: Array[Node] = []
var waypoints: Array[Vector3] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var point1 = Vector3(1.1, 0, 0)
	var point2 = Vector3(1.9, 0, 0)
	var point3 = Vector3(2.7, 0, 0)
	var point4 = Vector3(2.7, 0, 1.1)
	var point5 = Vector3(2.7, 0, 2.2)
	waypoints.append(point1)
	waypoints.append(point2)
	waypoints.append(point3)
	waypoints.append(point4)
	waypoints.append(point5)
	spawn_customer()
	pass # Replace with function body.
	
	
func destroy_front() -> void:
	if !multiplayer.is_server(): return
	if slots[0] == true:
		slots[0] = false
		front = null
		var c = customers.pop_at(0)
		c.queue_free()
		
	
func spawn_customer() -> void:
	if !multiplayer.is_server(): return
	if len(customers) >= 5: return
	
	var new_customer = customer.instantiate()
	customers.append(new_customer)
	new_customer.position = global_position + waypoints[4]
	new_customer.move_to(new_customer.position)
	NetHandler.spawner.get_parent().call_deferred("add_child", new_customer, true)

func move_customers() -> void:
	if !multiplayer.is_server(): return
	for i in range(len(customers)):
		if customers[i].slot > 0 and slots[customers[i].slot-1] == false:
			customers[i].move_to(global_position + waypoints[customers[i].slot - 1])
			slots[customers[i].slot] = false
			slots[customers[i].slot-1] = true
			customers[i].slot -= 1
			if customers[i].slot == 0:
				front = customers[i]
			 
	
func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	time += 1
	if time >= spawntime:
		time = 0
		spawn_customer()
		
	if time % 120 == 0:
		move_customers()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
