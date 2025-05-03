# malus.gd
class_name Malus
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var tags: Array[String] = []

func matches_tags(game_state: Dictionary) -> bool:
	for tag in tags:
		match tag:
			"co-op":
				if not game_state.is_coop:
					return false
			"singleplayer":
				if game_state.is_coop:
					return false
	return true
