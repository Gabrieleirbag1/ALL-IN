class_name IntOrFloat extends RefCounted
var int_value: int
var float_value: float

func _init(value: Variant) -> void:
	if typeof(value) == TYPE_INT:
		int_value = value
		float_value = float(value)
	elif typeof(value) == TYPE_FLOAT:
		float_value = value
		int_value = int(value)
	else:
		push_error("Value must be an int or a float, got: " + str(typeof(value)))
		int_value = 0
		float_value = 0.0

# Addition operator (+)
func _add(other: Variant) -> IntOrFloat:
	var result_value: float
	
	if other is IntOrFloat:
		result_value = self.float_value + other.float_value
	elif typeof(other) == TYPE_INT or typeof(other) == TYPE_FLOAT:
		result_value = self.float_value + other
	else:
		push_error("Cannot add IntOrFloat with " + str(typeof(other)))
		result_value = self.float_value
		
	return IntOrFloat.new(result_value)

# Subtraction operator (-)
func _sub(other: Variant) -> IntOrFloat:
	var result_value: float
	
	if other is IntOrFloat:
		result_value = self.float_value - other.float_value
	elif typeof(other) == TYPE_INT or typeof(other) == TYPE_FLOAT:
		result_value = self.float_value - other
	else:
		push_error("Cannot subtract IntOrFloat with " + str(typeof(other)))
		result_value = self.float_value
		
	return IntOrFloat.new(result_value)

# Less than operator (<)
func _lt(other: Variant) -> bool:
	if other is IntOrFloat:
		return self.float_value < other.float_value
	elif typeof(other) == TYPE_INT or typeof(other) == TYPE_FLOAT:
		return self.float_value < other
	else:
		push_error("Cannot compare IntOrFloat with " + str(typeof(other)))
		return false

# Optional: Implement other comparison operators for completeness
func _gt(other: Variant) -> bool:
	if other is IntOrFloat:
		return self.float_value > other.float_value
	elif typeof(other) == TYPE_INT or typeof(other) == TYPE_FLOAT:
		return self.float_value > other
	else:
		push_error("Cannot compare IntOrFloat with " + str(typeof(other)))
		return false

# String representation
func _to_string() -> String:
	if int_value == float_value:
		return str(int_value)
	else:
		return str(float_value)
