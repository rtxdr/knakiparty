extends CharacterBody2D

@export var MAXSPEED = 150
@export var ACCELERATRION = 3000
@export var FRICTION = 2400

var PROJECTILE: PackedScene = preload("res://object/rock.tscn")

@onready var raycast = $RayCast2D
@onready var camera = $Camera2D

@onready var axis = Vector2.ZERO

var mouse_position = null

func _physics_process(delta):
	move(delta)
	
	#RAYCAST POINT TO MOUSE CODE
	mouse_position = camera.get_local_mouse_position()
	raycast.look_at($testsprite.global_position)
	$testsprite.position = mouse_position
	
func get_input_axis():
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return axis.normalized()

func move(delta):
	axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		apply_friction(FRICTION * delta)
	else:
		apply_movement(axis * ACCELERATRION * delta)
	
	move_and_slide()

func apply_friction(amt):
	if velocity.length() > amt:
		velocity -= velocity.normalized() * amt
	
	else:
		velocity = Vector2.ZERO

func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(MAXSPEED)

func _on_shoot_timeout():
	if PROJECTILE:
		var rock = PROJECTILE.instantiate()
		get_tree().current_scene.add_child(rock)
		rock.global_position = self.global_position
		
		rock.rotation = raycast.rotation
