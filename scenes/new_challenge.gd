# new_challenge.gd
extends Control

signal challenge_created

@export var challenge_name_edit : LineEdit
@export var year_spinner : LineEdit
@export var season_option : OptionButton
@export var coop_check : CheckBox
@export var bus_check : CheckBox
@export var ginger_check : CheckBox
@export var create_button : Button
@export var back_button : Button

# Season options
var seasons = ["Spring", "Summer", "Fall", "Winter"]

func _ready():
	# Set up season dropdown
	for season in seasons:
		season_option.add_item(season)
	
	# Connect signals
	create_button.connect("pressed", Callable(self, "_on_create_pressed"))
	back_button.connect("pressed", Callable(self, "_on_back_pressed"))
	
	# Set default values
	challenge_name_edit.text = "My Stardew Challenge"
	year_spinner.value = 1
	season_option.selected = 0
	coop_check.button_pressed = false
	bus_check.button_pressed = false
	ginger_check.button_pressed = false
	
	# Add validation to enforce minimum year value of 1
	year_spinner.min_value = 1

func _on_create_pressed():
	if challenge_name_edit.text.strip_edges() == "":
		# Show error if no name provided
		OS.alert("Please enter a challenge name", "Missing Information")
		return
	
	# Get values from UI
	var challenge_name = challenge_name_edit.text
	var start_year = year_spinner.value
	var start_season = season_option.selected
	var is_coop = coop_check.button_pressed
	var bus_unlocked = bus_check.button_pressed
	var ginger_island_unlocked = ginger_check.button_pressed
	
	# Create new challenge in GameManager
	var game_manager = get_node("/root/GameManager")
	game_manager.create_new_challenge(challenge_name, start_year, start_season, is_coop)
	game_manager.update_game_settings(is_coop, bus_unlocked, ginger_island_unlocked)
	
	# Emit signal to change to dashboard scene
	emit_signal("challenge_created")

func _on_back_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
