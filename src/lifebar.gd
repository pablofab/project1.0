extends Control

onready var dmgenemy = get_parent().get_parent().get_node("Navigation/Enemy")






func _ready():
	pass # Replace with function body.



func lifebar():
	if dmgenemy._on_Timer_timeout():
		value = get_parent().get_parent().get_node("Player").health
	
