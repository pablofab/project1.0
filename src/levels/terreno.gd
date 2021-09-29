extends Spatial

onready var enemy = $Navigation/Enemy
onready var player = $Navigation/Player
onready var nav = $Navigation

func _ready():
	enemy.set_nav(nav)
	enemy.set_target(player)
