extends Area2D

@export var SPEED = 300
@export var SIZE = 0.3
@export var LIFETIME = 0.3

@onready var lifetimer = $death

func _ready():
	lifetimer.wait_time = LIFETIME
	scale[0] = SIZE
	scale[1] = SIZE

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += SPEED * direction * delta

func destroy():
	queue_free()

func _on_timer_timeout():
	destroy()
