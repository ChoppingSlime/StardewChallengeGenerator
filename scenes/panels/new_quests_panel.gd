# new_quests_panel.gd
extends Panel

signal quests_confirmed(selected_seasonal_category, selected_yearly_category)

@onready var title_label = $VBoxContainer/TitleLabel
@onready var seasonal_wheel = $VBoxContainer/WheelContainer/SeasonalWheel
@onready var yearly_wheel = $VBoxContainer/WheelContainer/YearlyWheel
@onready var seasonal_result_label = $VBoxContainer/ResultsContainer/SeasonalResultLabel
@onready var yearly_result_label = $VBoxContainer/ResultsContainer/YearlyResultLabel
@onready var confirm_button = $VBoxContainer/ConfirmButton

var current_season: String = ""
var current_year: int = 1
var selected_seasonal_category = null
var selected_yearly_category = null
var wheels_active = 0

func _ready():
	# Hide panel initially
	hide()
	
	# Connect signals
	confirm_button.connect("pressed", Callable(self, "_on_confirm_pressed"))
	seasonal_wheel.connect("wheel_stopped", Callable(self, "_on_seasonal_wheel_stopped"))
	yearly_wheel.connect("wheel_stopped", Callable(self, "_on_yearly_wheel_stopped"))
	
	# Disable confirm button until wheels are done
	confirm_button.disabled = true

func show_panel(season: String, year: int, seasonal_categories = [], yearly_categories = []):
	current_season = season
	current_year = year
	
	# Clear previous state
	selected_seasonal_category = null
	selected_yearly_category = null
	wheels_active = 0
	seasonal_result_label.text = ""
	yearly_result_label.text = ""
	
	# Set title
	title_label.text = "New Quests - Year " + str(year) + " " + season
	
	# Set up seasonal wheel
	if seasonal_categories.size() > 0:
		wheels_active += 1
		seasonal_wheel.set_wheel_items(seasonal_categories)
		seasonal_wheel.show()
		
		# Add a spin button under the wheel
		var seasonal_spin_button = $VBoxContainer/WheelContainer/SeasonalSpinButton
		seasonal_spin_button.text = "Spin Seasonal Quest Wheel"
		seasonal_spin_button.show()
		seasonal_spin_button.connect("pressed", Callable(self, "_on_spin_seasonal_pressed"))
	else:
		$VBoxContainer/WheelContainer/SeasonalSpinButton.hide()
		seasonal_wheel.hide()
	
	# Set up yearly wheel (only in Spring)
	if season == "Spring" and yearly_categories.size() > 0:
		wheels_active += 1
		yearly_wheel.set_wheel_items(yearly_categories)
		yearly_wheel.show()
		
		# Add a spin button under the wheel
		var yearly_spin_button = $VBoxContainer/WheelContainer/YearlySpinButton
		yearly_spin_button.text = "Spin Yearly Quest Wheel"
		yearly_spin_button.show()
		yearly_spin_button.connect("pressed", Callable(self, "_on_spin_yearly_pressed"))
	else:
		$VBoxContainer/WheelContainer/YearlySpinButton.hide()
		yearly_wheel.hide()
	
	# Disable confirm button until wheels are done
	confirm_button.disabled = (wheels_active > 0)
	
	# Show panel
	show()

func _on_spin_seasonal_pressed():
	seasonal_wheel.spin()
	$VBoxContainer/WheelContainer/SeasonalSpinButton.disabled = true

func _on_spin_yearly_pressed():
	yearly_wheel.spin()
	$VBoxContainer/WheelContainer/YearlySpinButton.disabled = true

func _on_seasonal_wheel_stopped(category):
	selected_seasonal_category = category
	wheels_active -= 1
	
	# Update result label
	seasonal_result_label.text = "Selected Seasonal Quest Category: " + category.name
	
	# Enable confirm button if all wheels done
	confirm_button.disabled = (wheels_active > 0)

func _on_yearly_wheel_stopped(category):
	selected_yearly_category = category
	wheels_active -= 1
	
	# Update result label
	yearly_result_label.text = "Selected Yearly Quest Category: " + category.name
	
	# Enable confirm button if all wheels done
	confirm_button.disabled = (wheels_active > 0)

func _on_confirm_pressed():
	# Emit signal with selected categories
	emit_signal("quests_confirmed", selected_seasonal_category, selected_yearly_category)
