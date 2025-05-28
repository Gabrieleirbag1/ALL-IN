extends Control

@onready var stat_icon: TextureRect = $StatIcon
@onready var stat_value: BBCodeRichTextLabel = $StatValue

func set_lucky_icon(new_stat: String):
	stat_icon.set_stat_icon(new_stat)

func set_lucky_value(value: Variant):
	var text: String = str(value)
	if value >= 0:
		text = "+" + text
	stat_value.set_bbcode_text(text, "left")

func set_lucky_color(rarity):
	var bg_color: String = Global.stat_rarity_colors[rarity]
	stat_value.set_font_color(bg_color)

func set_lucky_stat(new_stat: String, value: Variant, rarity: String):
	set_lucky_icon(new_stat)
	set_lucky_value(value)
	set_lucky_color(rarity)
