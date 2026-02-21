class_name PlayerGraphics
extends Node3D




@export var sprites: Array[AnimatedSprite3D]

enum BodyPart {EARS = 0, FACE = 1, BODYARMS = 2, LEG = 3}

enum CardDirection {NORTH = '0', SOUTH = '0', EAST = '0', WEST = '0'}
enum PlayerAction {IDLE, WALK}


@export var facing = CardDirection.NORTH
@export var state = PlayerAction.IDLE
@export var carrying = false

var lastFacing = facing
var lastCarrying = carrying

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if facing == CardDirection.EAST:
		for s in sprites:
			s.flip_h = true
	else:
		for s in sprites:
			s.flip_h = false
			
			
	match state:
		PlayerAction.IDLE:
			
			if carrying:
				sprites[BodyPart.BODYARMS].play()
			
		PlayerAction.WALK:
			pass
			
