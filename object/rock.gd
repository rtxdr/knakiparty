extends Area2D

@export var SPEED = 300

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += SPEED * direction * delta
	

func destroy():
	queue_free()


func _on_timer_timeout():
	destroy()
