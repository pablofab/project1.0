extends KinematicBody

export var max_speed = 10
export var acceleration = 70
export var friction = 60
export var air_friction = 10
export var gravity = -40
export var jump_impulse = 20
export var mouse_sensitivity = .1
export var controller_sensitivity = 3
export var rot_speed = 5

var camerap = true 
var current_weapon = 1
var current_player = 1

export (int, 0, 10) var push = 1

var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO


var shotgun_dmg = 50
var spread = 10

onready var health = 100
onready var i = 1

onready var spring_arm = $SpringArm
onready var pivot = $Pivot
onready var gun1 = $Hand/Gun1
onready var gun2 = $Hand/Gun2
onready var gun3 = $Hand/Gun3
onready var aimcast = $SpringArm/Camera/RayCast
onready var muzzle = $Hand/Gun1/muzzle
onready var player1 = get_parent().get_node("Player")
onready var player2 = get_parent().get_node("Player2")
onready var ambient = get_parent().get_node("WorldEnvironment")
onready var enemy = get_parent().get_node("Navigation/Enemy")

onready var damage = 40


func player_health():
	
	if health < 0 and i==1:
		
		i-= 1
		
		print("game over")
			
		#agregar pantalla de game over 
		


func player_select():
	
	if Input.is_action_just_pressed("ui_focus_next") and current_player == 1:
		current_player = 2
				
	elif Input.is_action_just_pressed("ui_focus_next") and current_player == 2:
		current_player = 1
	
	if current_player == 1 and i==1:
		player1.visible = true
		ambient.environment.set_background(2)
	else:
		player1.visible = false

	if current_player == 2 and i==1:
		player2.visible = true
		ambient.environment.set_background(0)
	else:
		player2.visible = false


func weapon_select():
	
	if Input.is_action_just_pressed("weapon1"):
		current_weapon = 1
	elif Input.is_action_just_pressed("weapon2"):
		current_weapon = 2
	elif Input.is_action_just_pressed("weapon3"):
		current_weapon = 3
		
	if current_weapon == 1:
		gun1.visible = true
		gun1.shoot()
	else:
		gun1.visible = false

	if current_weapon == 2:
		gun2.visible = true
		gun2.shoot()
	else:
		gun2.visible = false

	if current_weapon == 3:
		gun3.visible = true
		gun3.shoot()
	else:
		gun3.visible = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


		
	
func _unhandled_input(event):
	
							
		
	
	if event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("toggle_mouse_captured"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		spring_arm.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			

func _physics_process(delta):
	
	if Input.is_action_just_pressed("fire"):
		if aimcast.is_colliding():
			var target = aimcast.get_collider()
			if target.is_in_group("Enemy"):
				print("hit enemy")
				target.health -= damage
			
			
			
#			var bullet = get_world().direct_space_state
#			var collision = bullet.intersect_ray(muzzle.global_transform.origin, aimcast.get_collision_point())
			
#			if collision:
#				var target = collision.collider
				
#				if target.is_in_group("Enemy"):
#					print("hit enemy")
#					target.health -= damage
					
	weapon_select()
	
	player_health()
	
	player_select()
	
	var input_vector = get_input_vector()
	var direction = get_direction(input_vector)
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	apply_gravity(delta)
	update_snap_vector()
	jump()
	apply_controller_rotation()
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg2rad(-75), deg2rad(75))
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, 0.785398, false)
	for idx in get_slide_count():
		var collision = get_slide_collision(idx)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() * push)
	
	
func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return input_vector.normalized() if input_vector.length() > 1 else input_vector
	
	
func get_direction(input_vector):
	var direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction
	
	
func apply_movement(input_vector, direction, delta):
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * max_speed, acceleration * delta).x
		velocity.z = velocity.move_toward(direction * max_speed, acceleration * delta).z
#		pivot.look_at(global_transform.origin + direction, Vector3.UP)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, atan2(-input_vector.x, -input_vector.z), rot_speed * delta)
		
func apply_friction(direction, delta):
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		else:
			velocity.x = velocity.move_toward(direction * max_speed, air_friction * delta).x
			velocity.z = velocity.move_toward(direction * max_speed, air_friction * delta).z
		
func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jump_impulse)
	
	
func update_snap_vector():
	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN
	
	
func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap_vector = Vector3.ZERO
		velocity.y = jump_impulse
	if Input.is_action_just_released("jump") and velocity.y > jump_impulse / 2:
		velocity.y = jump_impulse / 2
		
		
func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		spring_arm.rotate_x(deg2rad(-axis_vector.y) * controller_sensitivity)
		




