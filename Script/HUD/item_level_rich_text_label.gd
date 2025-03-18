extends RichTextLabel

func _ready() -> void:
	set_item_level(1)

func set_item_level(item_level: int):
	var final_text: String = ""
	for star in range(item_level):
		final_text += "★"
	self.text = final_text
