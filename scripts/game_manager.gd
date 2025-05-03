# game_manager.gd
extends Node

signal seasonal_quest_changed(quest)
signal yearly_quest_changed(quest)
signal score_changed(new_score)
signal season_changed(year, season)
signal malus_added(malus)
signal malus_cleared()
signal reward_added(reward)

# Resource paths
const SEASONAL_QUESTS_PATH = "res://resources/quests/seasonal/"
const YEARLY_QUESTS_PATH = "res://resources/quests/yearly/"
const MALUSES_PATH = "res://resources/maluses/maluses.tres"
const REWARDS_PATH = "res://resources/rewards/rewards.tres"

# Category arrays
var seasonal_quest_categories: Array[SeasonalQuestCategory] = []
var yearly_quest_categories: Array[YearlyQuestCategory] = []
var maluses: MalusCollection
var rewards: RewardCollection

# Current challenge data
var challenge_data: ChallengeData

func _ready() -> void:
	randomize()
	load_resources()

func load_resources() -> void:
	# Load seasonal quest categories
	var dir = DirAccess.open(SEASONAL_QUESTS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var category = load(SEASONAL_QUESTS_PATH + file_name)
				if category is SeasonalQuestCategory:
					seasonal_quest_categories.append(category)
			file_name = dir.get_next()
	
	# Load yearly quest categories  
	dir = DirAccess.open(YEARLY_QUESTS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var category = load(YEARLY_QUESTS_PATH + file_name)
				if category is YearlyQuestCategory:
					yearly_quest_categories.append(category)
			file_name = dir.get_next()
	
	# Load maluses and rewards
	maluses = load(MALUSES_PATH)
	rewards = load(REWARDS_PATH)

func create_new_challenge(challenge_name: String, start_year: int, start_season: int) -> void:
	challenge_data = ChallengeData.new()
	challenge_data.name = challenge_name
	challenge_data.current_year = start_year
	challenge_data.current_season = start_season
	
	# Roll initial quests
	roll_yearly_quest()
	roll_seasonal_quest()
	
	season_changed.emit(challenge_data.current_year, challenge_data.current_season)


func roll_seasonal_quest() -> void:

	if seasonal_quest_categories.size() > 0:
		# Select random category
		var selected_category = seasonal_quest_categories[randi() % seasonal_quest_categories.size()]
		
		# Filter quests in this category
		var available_quests = []
		for quest in selected_category.quests:
			if quest.is_available_in_season(challenge_data.current_season) and \
			   quest.matches_tags(challenge_data.to_game_state()) and \
			   are_maluses_compatible(quest.conflicting_maluses):
				available_quests.append(quest)
		
		if available_quests.size() > 0:
			# Select random quest
			var selected_quest = available_quests[randi() % available_quests.size()]
			challenge_data.current_seasonal_quest = selected_quest
			emit_signal("seasonal_quest_changed", selected_quest)
			return
	
	# Fallback if no valid quests found
	print("Warning: No valid seasonal quests found!")


func roll_yearly_quest() -> void:
	# Only roll yearly quest in Spring
	if challenge_data.current_season != 0:
		return
		
	
	if yearly_quest_categories.size() > 0:
		# Select random category
		var selected_category = yearly_quest_categories[randi() % yearly_quest_categories.size()]
		
		# Filter quests in this category
		var available_quests = []
		for quest in selected_category.quests:
			if quest.matches_tags(challenge_data.to_game_state()) and \
			   are_maluses_compatible(quest.conflicting_maluses):
				available_quests.append(quest)
		
		if available_quests.size() > 0:
			# Select random quest
			var selected_quest = available_quests[randi() % available_quests.size()]
			challenge_data.current_yearly_quest = selected_quest
			emit_signal("yearly_quest_changed", selected_quest)
			return
	
	# Fallback if no valid quests found
	print("Warning: No valid yearly quests found!")


func are_maluses_compatible(conflicting_maluses: Array) -> bool:
	# Check if any active maluses conflict with the quest
	for active_malus in challenge_data.active_maluses:
		if active_malus.id in conflicting_maluses:
			return false
	return true

func roll_malus() -> void:
	# Filter maluses based on current game state
	var available_maluses = []
	for malus in maluses.maluses:
		if malus.matches_tags(challenge_data.to_game_state()):
			available_maluses.append(malus)
	
	if available_maluses.size() > 0:
		# Select random malus
		var selected_malus = available_maluses[randi() % available_maluses.size()]
		challenge_data.active_maluses.append(selected_malus)
		emit_signal("malus_added", selected_malus)

func roll_rewards(count: int = 3) -> Array:
	var selected_rewards = []
	
	if rewards.rewards.size() > 0:
		# Select random rewards
		for i in range(count):
			if rewards.rewards.size() > 0:
				var reward_index = randi() % rewards.rewards.size()
				var reward = rewards.rewards[reward_index]
				selected_rewards.append(reward)
				challenge_data.received_rewards.append(reward)
				emit_signal("reward_added", reward)
	
	return selected_rewards

func clear_maluses() -> void:
	challenge_data.active_maluses.clear()
	emit_signal("malus_cleared")

func add_score(points: int) -> void:
	challenge_data.score += points
	emit_signal("score_changed", challenge_data.score)

func proceed_to_next_season(seasonal_quest_completed: bool, yearly_quest_completed: bool = false) -> void:
	# Handle seasonal quest result
	if seasonal_quest_completed:
		add_score(1)
		clear_maluses()
		
		if challenge_data.current_seasonal_quest:
			challenge_data.completed_quests.append(challenge_data.current_seasonal_quest.id)
	else:
		roll_malus()
	
	# Handle yearly quest result if it's the end of Winter
	if challenge_data.current_season == 0:  # Spring, which means we just completed a year
		if yearly_quest_completed:
			var rewards = roll_rewards(3)
			
			if challenge_data.current_yearly_quest:
				challenge_data.completed_quests.append(challenge_data.current_yearly_quest.id)
		else:
			add_score(-4)
	
	# Advance season
	challenge_data.advance_season()
	
	# Roll new quests
	roll_seasonal_quest()
	if challenge_data.current_season == 0:  # Spring
		roll_yearly_quest()
	
	emit_signal("season_changed", challenge_data.current_year, challenge_data.current_season)

func update_game_settings(is_co_op: bool, bus_unlocked: bool, ginger_island_unlocked: bool) -> void:
	challenge_data.is_coop = is_co_op
	challenge_data.bus_unlocked = bus_unlocked
	challenge_data.ginger_island_unlocked = ginger_island_unlocked

func get_current_season_name() -> String:
	return challenge_data.get_season_name()

func get_active_maluses() -> Array:
	return challenge_data.active_maluses

func get_current_score() -> int:
	return challenge_data.score

func get_current_year() -> int:
	return challenge_data.current_year

func save_challenge(path: String) -> Error:
	return ResourceSaver.save(challenge_data, path)

func load_challenge(path: String) -> Error:
	var loaded_data = ResourceLoader.load(path)
	if loaded_data is ChallengeData:
		challenge_data = loaded_data
		emit_signal("seasonal_quest_changed", challenge_data.current_seasonal_quest)
		emit_signal("yearly_quest_changed", challenge_data.current_yearly_quest)
		emit_signal("score_changed", challenge_data.score)
		emit_signal("season_changed", challenge_data.current_year, challenge_data.current_season)
		return OK
	return ERR_FILE_NOT_FOUND
