class_name CenteredRichTextLabel extends RichTextLabel

func get_centered_text(text):
	var final_text = "[center]" + text + "[/center]"
	return final_text
	
func set_centered_text(text):
	self.text = get_centered_text(text)
