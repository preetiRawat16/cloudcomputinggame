extends Control

@onready var play_button = $play
@onready var exit_btn = $exit
@onready var leader_btn = $leaderboard
@onready var credit_btn = $credit
@onready var leaderboard_screen = preload("res://Scenes/LeaderboardScreen.tscn")
@onready var credit_screen = preload("res://Scenes/Credit.tscn")
func _ready():
	play_button.pressed.connect(_on_play_button_pressed)
	exit_btn.pressed.connect(_on_exit_button_pressed)
	leader_btn.pressed.connect(_on_leaderboard_button_pressed)
	credit_btn.pressed.connect(_on_credit_button_pressed)
func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/background.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

func _on_credit_button_pressed():
	var credit_instance = credit_screen.instantiate()
	get_tree().root.add_child(credit_instance)

func _on_leaderboard_button_pressed():
	
	var leaderboard_instance = leaderboard_screen.instantiate()
	
	get_tree().root.add_child(leaderboard_instance)
