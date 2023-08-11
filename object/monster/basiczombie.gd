extends CharacterBody2D

@export var speed = 100
@onready var player = get_parent().get_parent().get_node("players").get_child(0) #only host for now
var attackmode: bool
var attackingplayer: Node

func _physics_process(delta):
	if not attackmode:
		velocity = (position.direction_to(player.position) * speed) * (delta * 100)
		move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		attackingplayer = body
		attackingplayer.damage(10)

func _on_area_2d_body_exited(body):
	if body == attackingplayer:
		attackingplayer = null
