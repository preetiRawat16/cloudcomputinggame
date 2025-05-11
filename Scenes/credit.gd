extends Control

func _ready():
	$Panel/BackButton.pressed.connect(_on_back_button_pressed)
	
func _on_back_button_pressed():
	queue_free()
