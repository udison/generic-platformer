extends ParallaxBackground

var camera: Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_window().get_camera_2d()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$Sky.global_position.y = camera.global_position.y
