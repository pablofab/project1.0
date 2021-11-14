extends KinematicBody

export var speed = 5

var path = []
var cur_path_idx = 0
var velocity = Vector3.ZERO
var threshold = .1
var health = 200
var dmgtoplayer = 15

onready var nav = get_parent()
onready var player = get_parent().get_parent().get_node("Player")

func _physics_process(delta):
	if path.size() > 0:
		move_to_target()
		
func move_to_target():
	if global_transform.origin.distance_to(path[cur_path_idx]) < threshold:
		path.remove(0)
	else:
		var direction = path[cur_path_idx] - global_transform.origin
		velocity = direction.normalized() * speed
		move_and_slide(velocity, Vector3.UP)
		
func get_target_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)


func _process(delta):
	if health <= 0:
		queue_free()
		
		
		
		
func dmg_to_player():
	if path.size() < 5:
		player.health -= dmgtoplayer
		print("-15 dmg")
					

func _on_Timer_timeout():
	dmg_to_player() 
