extends ProgressBar

onready var dmgenemy = get_parent().get_parent().get_node("Navigation/Enemy")



func _ready():
	pass 


func _physics_process(delta):
	value = get_parent().get_parent().get_parent().get_node("Player").health
	
