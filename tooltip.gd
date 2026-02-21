extends CanvasLayer

var target:Node3D

func _process(_delta):
	if target == null:
		return

	var cam = get_viewport().get_camera_3d()
	var pos = cam.unproject_position(target.global_position)
	$Label.position = pos
