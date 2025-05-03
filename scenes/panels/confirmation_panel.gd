# confirmation_panel.gd
extends Panel

signal confirmed(seasonal_completed, yearly_completed)

@onready var title_label = $VBoxContainer/TitleLabel
@onready var seasonal_section = $VBoxContainer/SeasonalSection
@onready var seasonal_label = $VBoxContainer/SeasonalSection/SeasonalLabel
@onready var seasonal_completed_check = $VBoxContainer/SeasonalSection/SeasonalCompletedCheck
@onready var yearly_section = $VBoxContainer/YearlySection
@onready var yearly_label = $VBoxContainer/YearlySection/YearlyLabel
@onready var yearly_completed_check = $VBoxContainer/YearlySection/YearlyCompletedCheck
@onready var confirm_button = $VBoxContainer/ButtonSection/ConfirmButton
@onready var cancel_button = $VBoxContainer/ButtonSection/CancelButton

var current_season: String = ""
var current_year: int = 1
var seasonal_quest = null
var yearly_quest = null

func _ready():
	# Hide panel initially
	hide()
	
	# Connect signals
	confirm_button.connect("pressed", Callable(self, "_on_confirm_pressed"))
	cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))

func show_panel(season: String, year: int, seasonal_quest_data, yearly_quest_data = null):
	current_season = season
	current_year = year
	seasonal_quest = seasonal_quest_data
	yearly_quest = yearly_quest_data
	
	# Set title
	title_label.text = "Confirm Quest Completion - Year " + str(year) + " " + season
	
	# Set seasonal quest info
	if seasonal_quest:
		seasonal_label.text = "Did you complete the Seasonal Quest? (" + seasonal_quest.get_formatted_description(year) + ")"
	else:
		seasonal_label.text = "No active Seasonal Quest"
		seasonal_completed_check.disabled = true
	
	# Handle yearly quest (only show in Spring since it's for the previous year)
	if season == "Spring" and yearly_quest:
		yearly_section.visible = true
		yearly_label.text = "Did you complete the Yearly Quest? (" + yearly_quest.get_formatted_description(year - 1) + ")"
	else:
		yearly_section.visible = false
	
	# Reset checkboxes
	seasonal_completed_check.button_pressed = false
	yearly_completed_check.button_pressed = false
	
	# Show panel
	show()

func _on_confirm_pressed():
	# Emit signal with completion status
	emit_signal("confirmed", 
				seasonal_completed_check.button_pressed, 
				yearly_completed_check.button_pressed if yearly_section.visible else false)

func _on_cancel_pressed():
	# Hide panel without confirming
	hide()
