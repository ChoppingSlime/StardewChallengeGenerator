# yearly_quest.gd
class_name YearlyQuest
extends Resource

@export var id: String
@export var category: String
@export var description: String
@export var tags: Array[String] = []
@export var conflicting_maluses: Array[String] = []
@export var difficulty_multiplier: float = 1.0  # Used to scale difficulty with year

func get_formatted_description(current_year: int) -> String:
	# Replace X with scaled difficulty value based on year
	var difficulty_value = int(20 * difficulty_multiplier * current_year)
	var formatted_desc = description.replace("X", str(difficulty_value))
	
	# Replace Y with a random target if needed
	# This would be filled in when the quest is selected
	return formatted_desc

func matches_tags(game_state: Dictionary) -> bool:
	# Similar to the seasonal quest function
	for tag in tags:
		match tag:
			"first-year":
				if game_state.current_year > 1:
					return false
			"post-year-one":
				if game_state.current_year < 2:
					return false
			"second-year":
				if game_state.current_year != 2:
					return false
			"post-year-two":
				if game_state.current_year < 3:
					return false
			"co-op":
				if not game_state.is_coop:
					return false
			"singleplayer":
				if game_state.is_coop:
					return false
			"bus-unlocked":
				if not game_state.bus_unlocked:
					return false
	return true
