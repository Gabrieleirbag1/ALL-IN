class_name BBCodeRichTextLabel extends RichTextLabel

func get_bbcode_text(bbcode_text: String, bbcode: String = "center") -> String:
	var final_text: String = "[" + bbcode + "]" + bbcode_text + "[/" + bbcode + "]"
	return final_text
	
func set_bbcode_text(bbcode_text: String, bbcode: String = "center"):
	self.text = get_bbcode_text(bbcode_text, bbcode)
	
func set_font_color(color: String):
	self.add_theme_color_override("default_color", color)
