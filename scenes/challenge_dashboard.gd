# challenge_dashboard.gd
extends Control

@onready var ui_controller = $UIController

func _ready():
	# Initialize UI controller
	ui_controller._update_ui_from_challenge_data()
	
	# Connect to back button
	$HeaderSection/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))
	
	# Make sure all panels are hidden initially
	$Panels/ConfirmationPanel.hide()
	$Panels/ResultsPanel.hide()
	$Panels/NewQuestsPanel.hide()

func _on_back_pressed():
	# Confirm before going back to main menu
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Return to Main Menu"
	confirm_dialog.dialog_text = "Are you sure you want to return to the main menu? Any unsaved progress will be lost."
	confirm_dialog.get_ok_button().text = "Yes"
	confirm_dialog.get_cancel_button().text = "No"
	
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()
	
	confirm_dialog.connect("confirmed", Callable(self, "_confirm_back_to_menu"))

func _confirm_back_to_menu():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
