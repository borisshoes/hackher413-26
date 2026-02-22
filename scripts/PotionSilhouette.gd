extends Node

const indexconversion = [0,0,2,1,0,4,3]

@export var potionID:int

@export var potionsprites:Array[Sprite2D]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in potionsprites:
		if(indexconversion[potionID] == 4):
			if i.name == "Out":
				i.region_rect.position.x = 48
				i.region_rect.position.y = 32
			else:
				i.region_rect.position.x = 32
				i.region_rect.position.y = 32
		else:
			i.region_rect.position.x = indexconversion[potionID] * 16
			if i.name == "Out":
				i.region_rect.position.y = 0
			else:
				i.region_rect.position.y = 16
		
			
	
