class_name FittedLabel extends Label

@export var min_font_size: int = 8
@export var max_font_size: int = 30
@export var initial_font_size: int = 30

func _ready():
	add_theme_font_size_override("font_size", initial_font_size)

func set_text_fit(new_text: String) -> void:
	text = new_text
	resize_font_to_fit()

func resize_font_to_fit() -> void:
	var font_size = max_font_size
	add_theme_font_size_override("font_size", font_size)
	
	var label_size = size
	
	while font_size > min_font_size:
		var text_size = get_theme_font("font").get_string_size(
			text, 
			HORIZONTAL_ALIGNMENT_LEFT, 
			-1, 
			font_size
		)
		
		if text_size.x <= label_size.x and text_size.y <= label_size.y:
			break
			
		font_size -= 1
		add_theme_font_size_override("font_size", font_size)
