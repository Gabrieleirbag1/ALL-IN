extends Control

@onready var stat_icon: TextureRect = $StatIcon
@onready var stat_value: BBCodeRichTextLabel = $StatValue

func play_animation():
	modulate.a = 0
	scale = Vector2(0.7, 0.7)
	
	# POP
	var pop_tween: Tween = create_tween()
	pop_tween.parallel().tween_property(self, "modulate:a", 1.0, 0.5)
	pop_tween.parallel().tween_property(self, "scale", Vector2(1.15, 1.15), 0.3)
	pop_tween.tween_property(self, "scale", Vector2(1, 1), 0.3)

	# ELEVATION
	var elevation_tween: Tween = create_tween()
	elevation_tween.tween_interval(0.4)
	elevation_tween.tween_property(self, "position:y", position.y - 50, 4)
	
	# FADE
	var fade_tween: Tween = create_tween()
	fade_tween.tween_interval(2.5)
	fade_tween.tween_property(self, "modulate:a", 0.0, 1.0)
	
	fade_tween.tween_callback(queue_free)

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
