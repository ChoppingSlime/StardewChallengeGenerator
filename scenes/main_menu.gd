# main_menu.gd
extends Control

@export var new_challenge_button : Button
@export var load_challenge_button : Button
@export var exit_button : Button
@export var title_label : Label

func _ready():
	# Connect button signals
	new_challenge_button.connect("pressed", Callable(self, "_on_new_challenge_pressed"))
	load_challenge_button.connect("pressed", Callable(self, "_on_load_challenge_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_exit_pressed"))
	
	# Set title text
	title_label.text = "Stardew Valley Challenge Generator"

func _on_new_challenge_pressed():
	# Go to new challenge scene
	get_tree().change_scene_to_file("res://scenes/new_challenge.tscn")

func _on_load_challenge_pressed():
	# Show file dialog to load challenge
	var load_dialog = FileDialog.new()
	load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_dialog.access = FileDialog.ACCESS_USERDATA
	load_dialog.filters = ["*.tres ; Challenge Data"]
	load_dialog.current_path = "user://challenges/"
	load_dialog.title = "Load Challenge"
	
	add_child(load_dialog)
	load_dialog.popup_centered(Vector2(500, 400))
	
	load_dialog.connect("file_selected", Callable(self, "_on_load_file_selected"))

func _on_load_file_selected(path):
	# Load the selected challenge file
	var game_manager = get_node("/root/GameManager")
	var result = game_manager.load_challenge(path)
	
	if result == OK:
		# Switch to dashboard scene
		get_tree().change_scene_to_file("res://scenes/challenge_dashboard.tscn")
	else:
		# Show error
		OS.alert("Failed to load challenge file", "Error")

func _on_exit_pressed():
	# Exit the application
	get_tree().quit()
