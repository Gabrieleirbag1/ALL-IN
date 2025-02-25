class_name CenteredRichTextLabel extends RichTextLabel

func get_centered_text(text: String) -> String:
	var final_text: String = "[center]" + text + "[/center]"
	return final_text
	
func set_centered_text(text: String):
	self.text = get_centered_text(text)
