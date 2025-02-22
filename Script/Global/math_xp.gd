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
	
	GameController.xp_progress(total_experience, get_total_experience_to_reach_level(level), get_total_experience_to_reach_level(level+1))
	level_up(level)
	# show_level_counters()
	return level

func level_up(new_level: int):
	while level_iterations.size() < new_level:
		level_iterations.append(0)
		if new_level != 1:
			GameController.level_up()
	if current_level != new_level:
		current_level = new_level

func show_level_counters():
	level_iterations[current_level - 1] += 1
	print("Niveau actuel: ", current_level)
	print("Progression par niveau: ", level_iterations)

func get_experience_required_for_next_level(current_level: int) -> float:
	return BASE_LEVEL_XP * pow(GROWTH_RATE, current_level - 1)

func get_total_experience_to_reach_level(level: int) -> float:
	if level <= 1:
		return 0.0
	return (BASE_LEVEL_XP * (pow(GROWTH_RATE, level - 1) - 1)) / (GROWTH_RATE - 1)
