
# challenge_data.gd
class_name ChallengeData
extends Resource

@export var name: String = "New Challenge"
@export var current_year: int = 1
@export var current_season: int = 0  # 0=Spring, 1=Summer, 2=Fall, 3=Winter
@export var score: int = 0
@export var current_seasonal_quest: SeasonalQuest = null  # SeasonalQuest type
@export var current_yearly_quest: YearlyQuest = null  # YearlyQuest type
@export var active_maluses: Array[Malus] = []
@export var received_rewards: Array[Reward] = []
@export var completed_quests: Array[String] = []  # IDs of completed quests
@export var is_coop: bool = false
@export var bus_unlocked: bool = false
@export var ginger_island_unlocked: bool = false

func to_game_state() -> Dictionary:
	return {
		"current_year": current_year,
		"current_season": current_season,
		"is_coop": is_coop,
		"bus_unlocked": bus_unlocked,
		"ginger_island_unlocked": ginger_island_unlocked,
		"completed_quests": completed_quests
	}

func advance_season() -> void:
	current_season += 1
	if current_season > 3:
		current_season = 0
		current_year += 1

func get_season_name() -> String:
	match current_season:
		0: return "Spring"
		1: return "Summer"
		2: return "Fall"
		3: return "Winter"
		_: return "Unknown"
