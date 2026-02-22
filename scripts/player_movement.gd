extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 0

#used by server

#Used by client
@export var holding_something: Node = null
@onready var detector = $InteractionDetector
var nearby_interactables := []

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

	if Input.is_action_just_pressed("interact"):
		try_interact_player()

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
	
	

func _ready():
	detector.area_entered.connect(_on_area_entered)
	detector.area_exited.connect(_on_area_exited)

func _on_area_entered(area):
	var obj = area.get_parent()
	if obj.has_method("try_interact"):
		nearby_interactables.append(obj)

func _on_area_exited(area):
	var obj = area.get_parent()
	nearby_interactables.erase(obj)

func try_interact_player():
	if nearby_interactables.is_empty():
		return

	nearby_interactables[0].try_interact(self)
