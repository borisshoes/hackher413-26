extends Sprite2D

@export var numSprites: Array[Sprite2D]
@export var numOffset = 16
@export var realNum = 0
@export var base = 10


func set_num_place(place:int) -> void:
	numSprites[place].region_rect.position.x = (realNum/((int)(pow(base,place)))%base) * numOffset



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(len(numSprites)):
		set_num_place(i)
