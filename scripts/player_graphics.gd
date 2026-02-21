class_name PlayerGraphics
extends Node3D


@onready var player_body = $".."

@export var sprites: Array[AnimatedSprite3D]

enum BodyPart {EARS = 0, FACE = 1, BODYARMS = 2, LEG = 3}

enum CardDirection {SOUTH = 0, WEST = 1, NORTH = 2, EAST = 3}
enum PlayerAction {IDLE, WALK}


@export var facing := CardDirection.NORTH
@export var state := PlayerAction.IDLE
@export var carrying := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if player_body.velocity.length() > 0:
		state = PlayerAction.WALK
	else:
		state = PlayerAction.IDLE
	
	if player_body.holding_something != null:
		carrying = true
	else:
		carrying = false
	
	if player_body.velocity.x < 0:
		facing = CardDirection.WEST
	elif player_body.velocity.x > 0:
		facing = CardDirection.EAST
	
	if player_body.velocity.z < 0:
		facing = CardDirection.NORTH
	elif player_body.velocity.z > 0:
		facing = CardDirection.SOUTH
		
	
	var tempDir = facing
	if tempDir == CardDirection.EAST:
		tempDir = CardDirection.WEST
	
	var dirstr = str(tempDir)
	
	for s in sprites:
		s.flip_h = (facing == CardDirection.EAST)
		
		match state:
			PlayerAction.IDLE:
				if s.animation != "Idle_" + str(dirstr):
					s.play("Idle_" + dirstr)
			PlayerAction.WALK:
				if s.animation != "Walk_" + dirstr:
					s.play("Walk_" + dirstr)
	if carrying:
		sprites[BodyPart.BODYARMS].play("Hold_" + dirstr)
