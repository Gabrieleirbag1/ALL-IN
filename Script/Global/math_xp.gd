extends Node

const BASE_LEVEL_XP = 100.0

func calculate_level_from_exp(experience: float) -> int:
	var level = sqrt(experience / BASE_LEVEL_XP) + 0.5
	
	if level < 1.0:
		level = 1.0
	
	return floor(level)
