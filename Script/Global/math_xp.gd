extends Node

const BASE_LEVEL_XP = 100.0
const GROWTH_RATE = 1.5

var level_iterations = []
var current_level = 1

func calculate_level_from_exp(total_experience: float) -> int:
	var level = 1
	var xp_requise = BASE_LEVEL_XP
	var xp_restante = total_experience
	
	while xp_restante >= xp_requise:
		xp_restante -= xp_requise
		level += 1
		xp_requise *= GROWTH_RATE

	update_level_counters(level)
	return level

func update_level_counters(new_level: int):
	while level_iterations.size() < new_level:
		level_iterations.append(0)
	
	if current_level != new_level:
		current_level = new_level
	
	level_iterations[current_level - 1] += 1
	print("Niveau actuel: ", current_level)
	print("Progression par niveau: ", level_iterations)
