extends Sprite2D
var time: int = 10000
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	time = ($Minute.realNum * 60 + $Second.realNum) * 60

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	time -= 1
	if time < 0:
		time = 0
	var fake_time = float(time)/float(60)
	var new_real = int(fake_time)
	var minutes = new_real/60
	var seconds = new_real - (minutes * 60)
	$Minute.realNum = minutes
	$Second.realNum = seconds
