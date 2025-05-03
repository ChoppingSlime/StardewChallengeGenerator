# results_panel.gd
extends Panel

signal continue_pressed(seasonal_completed, yearly_completed, selected_malus, selected_rewards)

@onready var title_label = $VBoxContainer/TitleLabel
@onready var results_container = $VBoxContainer/ResultsContainer
@onready var message_list = $VBoxContainer/ResultsContainer/MessageList
@onready var wheel_container = $VBoxContainer/WheelContainer
@onready var malus_wheel = $VBoxContainer/WheelContainer/MalusWheel
@onready var reward_wheel = $VBoxContainer/WheelContainer/RewardWheel
@onready var continue_button = $VBoxContainer/ContinueButton

var seasonal_result: String = ""
var yearly_result: String = ""
var selected_malus = null
var selected_rewards = []
var wheels_active = 0

func _ready():
	# Hide panel initially
	hide()
	
	# Connect signals
	continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))
	malus_wheel.connect("wheel_stopped", Callable(self, "_on_malus_wheel_stopped"))
	reward_wheel.connect("wheel_stopped", Callable(self, "_on_reward_wheel_stopped"))
	
	# Disable continue button until wheels are done
	continue_button.disabled = true

func show_panel(seasonal_result_text: String, yearly_result_text: String = ""):
	# Store results
	seasonal_result = seasonal_result_text
	yearly_result = yearly_result_text
	
	# Clear previous state
	for child in message_list.get_children():
		child.queue_free()
	
	selected_malus = null
	selected_rewards = []
	wheels_active = 0
	
	# Set title
	title_label.text = "Quest Results"
	
	# Hide wheels initially
	malus_wheel.hide()
	reward_wheel.hide()
	
	# Enable continue button if no wheels
	continue_button.disabled = (wheels_active > 0)
	
	# Show panel
	show()

func add_message(message: String):
	var label = Label.new()
	label.text = message
	message_list.add_child(label)

func prepare_malus_wheel(maluses_collection):
	# Filter maluses based on game state
	var game_manager = get_node("/root/GameManager")
	var available_maluses = []
	
	for malus in maluses_collection:
		if malus.matches_tags(game_manager.challenge_data.to_game_state()):
			available_maluses.append(malus)
	
	if available_maluses.size() > 0:
		wheels_active += 1
		continue_button.disabled = true
		
		# Set up and show malus wheel
		malus_wheel.set_wheel_items(available_maluses)
		malus_wheel.show()
		
		# Add a spin button
		var spin_button = Button.new()
		spin_button.text = "Spin Malus Wheel"
		spin_button.connect("pressed", Callable(self, "_on_spin_malus_pressed"))
		message_list.add_child(spin_button)

func prepare_reward_wheel(rewards_collection):
	if rewards_collection.size() > 0:
		wheels_active += 1
		continue_button.disabled = true
		
		# Set up and show reward wheel
		reward_wheel.set_wheel_items(rewards_collection)
		reward_wheel.show()
		
		# Add a spin button
		var spin_button = Button.new()
		spin_button.text = "Spin Reward Wheel"
		spin_button.connect("pressed", Callable(self, "_on_spin_reward_pressed"))
		message_list.add_child(spin_button)

func _on_spin_malus_pressed():
	malus_wheel.spin()
	
	# Remove the spin button
	var spin_button = message_list.get_child(message_list.get_child_count() - 1)
	if spin_button is Button:
		spin_button.queue_free()

func _on_spin_reward_pressed():
	reward_wheel.spin()
	
	# Remove the spin button
	var spin_button = message_list.get_child(message_list.get_child_count() - 1)
	if spin_button is Button:
		spin_button.queue_free()

func _on_malus_wheel_stopped(malus):
	selected_malus = malus
	wheels_active -= 1
	
	# Add selected malus to message list
	add_message("Malus received: " + malus.name + " - " + malus.description)
	
	# Enable continue button if all wheels done
	continue_button.disabled = (wheels_active > 0)

func _on_reward_wheel_stopped(reward):
	selected_rewards.append(reward)
	wheels_active -= 1
	
	# Add selected reward to message list
	add_message("Reward received: " + reward.name + " - Item Code: [" + reward.item_code + "]")
	
	# Enable continue button if all wheels done
	continue_button.disabled = (wheels_active > 0)

func _on_continue_pressed():
	# Emit signal with results
	emit_signal("continue_pressed", 
				seasonal_result == "completed", 
				yearly_result == "completed", 
				selected_malus, 
				selected_rewards)
