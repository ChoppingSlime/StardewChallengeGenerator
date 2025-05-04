# ui_controller.gd
extends Control

# Scene references
@onready var season_year_display : Label
@onready var score_display : Label
@onready var malus_list : VBoxContainer
@onready var seasonal_quest_display = $QuestSection/SeasonalQuestDisplay
@onready var yearly_quest_display = $QuestSection/YearlyQuestDisplay
@onready var rewards_list = $RewardsSection/RewardsList

# Toggle buttons
@onready var coop_toggle = $SettingsSection/CoopToggle
@onready var bus_toggle = $SettingsSection/BusToggle
@onready var ginger_island_toggle = $SettingsSection/GingerIslandToggle

# Action buttons
@onready var next_season_button = $ActionsSection/NextSeasonButton
@onready var save_button = $ActionsSection/SaveButton
@onready var load_button = $ActionsSection/LoadButton

# Panels
@onready var confirmation_panel = $Panels/ConfirmationPanel
@onready var results_panel = $Panels/ResultsPanel
@onready var new_quests_panel = $Panels/NewQuestsPanel

# Access to GameManager singleton
var game_manager

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	
	# Connect signals from GameManager
	game_manager.connect("seasonal_quest_changed", Callable(self, "_on_seasonal_quest_changed"))
	game_manager.connect("yearly_quest_changed", Callable(self, "_on_yearly_quest_changed"))
	game_manager.connect("score_changed", Callable(self, "_on_score_changed"))
	game_manager.connect("season_changed", Callable(self, "_on_season_changed"))
	game_manager.connect("malus_added", Callable(self, "_on_malus_added"))
	game_manager.connect("malus_cleared", Callable(self, "_on_malus_cleared"))
	game_manager.connect("reward_added", Callable(self, "_on_reward_added"))
	
	# Connect UI control signals
	next_season_button.connect("pressed", Callable(self, "_on_next_season_pressed"))
	coop_toggle.connect("toggled", Callable(self, "_on_game_setting_changed"))
	bus_toggle.connect("toggled", Callable(self, "_on_game_setting_changed"))
	ginger_island_toggle.connect("toggled", Callable(self, "_on_game_setting_changed"))
	save_button.connect("pressed", Callable(self, "_on_save_pressed"))
	load_button.connect("pressed", Callable(self, "_on_load_pressed"))
	
	# Connect panel signals
	confirmation_panel.connect("confirmed", Callable(self, "_on_confirmation_panel_confirmed"))
	results_panel.connect("continue_pressed", Callable(self, "_on_results_panel_continue"))
	new_quests_panel.connect("quests_confirmed", Callable(self, "_on_new_quests_confirmed"))

func _on_seasonal_quest_changed(quest):
	if quest:
		seasonal_quest_display.update_quest(quest)
	else:
		seasonal_quest_display.clear()

func _on_yearly_quest_changed(quest):
	if quest:
		yearly_quest_display.update_quest(quest)
	else:
		yearly_quest_display.clear()

func _on_score_changed(new_score):
	score_display.update_score(new_score)

func _on_season_changed(year, season):
	season_year_display.update_display(year, game_manager.get_current_season_name())

func _on_malus_added(malus):
	malus_list.add_malus(malus)

func _on_malus_cleared():
	malus_list.clear_maluses()

func _on_reward_added(reward):
	rewards_list.add_reward(reward)

func _on_next_season_pressed():
	confirmation_panel.show_panel(game_manager.get_current_season_name(), 
							  game_manager.get_current_year(),
							  game_manager.challenge_data.current_seasonal_quest,
							  game_manager.challenge_data.current_yearly_quest)

func _on_game_setting_changed(_toggled = null):
	game_manager.update_game_settings(
		coop_toggle.button_pressed,
		bus_toggle.button_pressed,
		ginger_island_toggle.button_pressed
	)

func _on_confirmation_panel_confirmed(seasonal_completed: bool, yearly_completed: bool):
	confirmation_panel.hide()
	
	# Show results panel with outcomes
	var seasonal_result = "completed" if seasonal_completed else "failed"
	var yearly_result = ""
	
	if game_manager.challenge_data.current_season == 0:  # Spring
		yearly_result = "completed" if yearly_completed else "failed"
	
	results_panel.show_panel(seasonal_result, yearly_result)
	
	# Process the quest results in the background
	# The actual game state won't change until continue is pressed
	if seasonal_completed:
		results_panel.add_message("Seasonal Quest completed! +1 point")
		if game_manager.challenge_data.active_maluses.size() > 0:
			results_panel.add_message("All active maluses cleared!")
	else:
		results_panel.add_message("Seasonal Quest failed! Rolling a malus...")
		results_panel.prepare_malus_wheel(game_manager.maluses.maluses)
	
	if game_manager.challenge_data.current_season == 0:  # Spring
		if yearly_completed:
			results_panel.add_message("Yearly Quest completed! Rolling rewards...")
			results_panel.prepare_reward_wheel(game_manager.rewards.rewards)
		else:
			results_panel.add_message("Yearly Quest failed! -4 points")

func _on_results_panel_continue(seasonal_completed: bool, yearly_completed: bool, selected_malus = null, selected_rewards = []):
	results_panel.hide()
	
	# Update game state with the results
	game_manager.proceed_to_next_season(seasonal_completed, yearly_completed)
	
	# Show new quests panel
	new_quests_panel.show_panel(
		game_manager.get_current_season_name(),
		game_manager.get_current_year(),
		game_manager.seasonal_quest_categories if game_manager.seasonal_quest_categories.size() > 0 else [],
		game_manager.yearly_quest_categories if game_manager.challenge_data.current_season == 0 and game_manager.yearly_quest_categories.size() > 0 else []
	)

func _on_new_quests_confirmed(selected_seasonal_category, selected_yearly_category = null):
	new_quests_panel.hide()
	
	# Force the game manager to select quests from the chosen categories
	# This would involve modifying the game_manager to support this functionality
	
	# For now, let's just roll new quests
	game_manager.roll_seasonal_quest()
	if game_manager.challenge_data.current_season == 0:  # Spring
		game_manager.roll_yearly_quest()

func _on_save_pressed():
	var save_dialog = FileDialog.new()
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.access = FileDialog.ACCESS_USERDATA
	save_dialog.filters = ["*.tres ; Challenge Data"]
	save_dialog.current_path = "user://challenges/"
	save_dialog.title = "Save Challenge"
	
	add_child(save_dialog)
	save_dialog.popup_centered(Vector2(500, 400))
	
	save_dialog.connect("file_selected", Callable(self, "_on_save_file_selected"))

func _on_save_file_selected(path):
	var result = game_manager.save_challenge(path)
	if result != OK:
		print("Error saving challenge: ", result)

func _on_load_pressed():
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
	var result = game_manager.load_challenge(path)
	if result != OK:
		print("Error loading challenge: ", result)
	
	# Update UI with loaded data
	_update_ui_from_challenge_data()

func _update_ui_from_challenge_data():
	# Update toggle buttons
	coop_toggle.button_pressed = game_manager.challenge_data.is_coop
	bus_toggle.button_pressed = game_manager.challenge_data.bus_unlocked
	ginger_island_toggle.button_pressed = game_manager.challenge_data.ginger_island_unlocked
	
	# Update displays
	season_year_display.update_display(
		game_manager.challenge_data.current_year, 
		game_manager.get_current_season_name()
	)
	
	score_display.update_score(game_manager.challenge_data.score)
	
	# Clear and repopulate lists
	malus_list.clear_maluses()
	for malus in game_manager.challenge_data.active_maluses:
		malus_list.add_malus(malus)
	
	rewards_list.clear_rewards()
	for reward in game_manager.challenge_data.received_rewards:
		rewards_list.add_reward(reward)
