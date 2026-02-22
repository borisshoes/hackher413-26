extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 0

#used by server

#Used by client
@export var holding_something: Node = null
var active_workstation: Workstation = null

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
	if not is_multiplayer_authority(): return
	
	$Camera3D.make_current()

func _physics_process(delta: float) -> void:
	
	#Make this not execute unless you own the player
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	
	
func take_hand() -> void:
	holding_something.queue_free()
	holding_something = null
	
	

func set_active_workstation(ws):
	active_workstation = ws

func clear_active_workstation(ws):
	if active_workstation == ws:
		close_current_workstation()
		active_workstation = null

func close_current_workstation():
	if active_workstation:
		if multiplayer.is_server():
			active_workstation.end_use_request()
		else:
			active_workstation.end_use_request.rpc_id(1)


func _input(event):
	if event.is_action_pressed("interact") and active_workstation:
		var my_peer_id = multiplayer.get_unique_id()
		print("[Player] Interact pressed, peer_id: %d" % my_peer_id)
		if multiplayer.is_server():
			active_workstation.request_use(my_peer_id)
		else:
			active_workstation.request_use.rpc_id(1, my_peer_id)
