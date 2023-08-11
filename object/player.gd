extends CharacterBody2D

@export var MAXSPEED = 120
@export var SPEEDMULT = 1
@export var ACCELERATRION = 3000
@export var FRICTION = 2400

@export var reloadtime = 2
@export var shootspeed = 0.2
@export var clipsize = 5

var PROJECTILE: PackedScene = preload("res://object/rock.tscn")
var ZOMBIE: PackedScene = preload("res://object/monster/basiczombie.tscn")

@onready var raycast = $RayCast2D
@onready var camera = $Camera2D
@onready var playersprite = $AnimatedSprite2D
@onready var shoottimer = $shoot
@onready var shootintervaltimer = $shootinterval

@onready var axis = Vector2.ZERO

var mouse_position = null
var shooting: bool

#func created(username):
#	$Label.text = username

func _ready():
	if not is_multiplayer_authority(): return
	camera.make_current()
	$target.show()

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func updatestats():
	shoottimer.wait_time = reloadtime + (shootspeed * clipsize)
	shootintervaltimer.wait_time = shootspeed

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	move(delta)
	updatestats()
	var velocitytotal = abs(velocity[0])+abs(velocity[1])
	
	
	#RAYCAST POINT TO MOUSE CODE
	mouse_position = camera.get_local_mouse_position()
	raycast.look_at(mouse_position)
	$target.position = mouse_position
	#END
	
	if Input.is_action_just_pressed("debugcreate"):
		var zombie = ZOMBIE.instantiate()
		get_tree().current_scene.get_child(4).add_child(zombie)
		zombie.position = mouse_position
	
	animateplayer.rpc(shooting,Input.is_action_just_pressed("move_left"),
	Input.is_action_just_pressed("move_right"), velocity, SPEEDMULT)
	
	#debug update
	$debug.text = (str(velocitytotal) + "\n" + str(shoottimer.time_left) + "\n" +
	str(shootintervaltimer.time_left)+"\n"+str(clipsize))

@rpc("call_local")
func animateplayer(state,left,right,vel,smult):
	if left:
		playersprite.scale[0] = -1.5
	if right:
		playersprite.scale[0] = 1.5
		
	if state:
		playersprite.play("throw")
	else:
		if vel:
			playersprite.play("walk",smult)
		else:
			playersprite.play("default")
	
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
	velocity = velocity.limit_length(MAXSPEED*SPEEDMULT)

func _on_shoot_timeout():
	if not is_multiplayer_authority(): return
	shootrock.rpc(clipsize)

@rpc("call_local")
func shootrock(clip):
	if PROJECTILE:
		shooting = true
		for i in range(clip):
			shootintervaltimer.start()
			var rock = PROJECTILE.instantiate()
			get_tree().current_scene.add_child(rock)
			rock.global_position = self.global_position
			
			rock.rotation = raycast.rotation
			if clipsize > 1:
				await shootintervaltimer.timeout
		shooting = false
