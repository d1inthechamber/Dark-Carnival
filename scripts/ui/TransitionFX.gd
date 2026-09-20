extends Control

@onready var flash: ColorRect = $Flash
@onready var slash_a: ColorRect = $SlashA
@onready var slash_b: ColorRect = $SlashB
@onready var caption: Label = $Caption

var active_tween: Tween

func impact(text: String = "", tint: Color = Color(0.95, 0.08, 0.22, 1.0)) -> void:
	_stop_active()
	_reset_layers()
	flash.color = tint
	slash_a.color = tint
	caption.text = text
	caption.rotation = deg_to_rad(-2.0)

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(flash, "modulate:a", 0.68, 0.035)
	active_tween.parallel().tween_property(caption, "modulate:a", 1.0, 0.045)
	active_tween.parallel().tween_property(caption, "scale", Vector2(1.05, 1.05), 0.045)
	active_tween.tween_interval(0.055)
	active_tween.tween_property(flash, "modulate:a", 0.0, 0.22)
	active_tween.parallel().tween_property(caption, "modulate:a", 0.0, 0.22)
	active_tween.parallel().tween_property(caption, "scale", Vector2.ONE, 0.22)

func card_play(card_name:String, text:String, tint:Color) -> void:
	_stop_active()
	_reset_layers()
	flash.color = tint.darkened(0.35)
	slash_a.color = tint
	slash_b.color = Color(0.96, 0.93, 0.82, 1)
	caption.text = text
	caption.rotation = 0.0
	caption.scale = Vector2(0.82, 0.82)
	slash_a.scale.x = 0.02
	slash_b.scale.x = 0.02

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	match card_name:
		"HATCHET":
			slash_a.rotation = -0.34
			slash_b.rotation = -0.27
			active_tween.tween_property(slash_a, "modulate:a", 0.92, 0.02)
			active_tween.parallel().tween_property(slash_a, "scale:x", 1.15, 0.09)
			active_tween.parallel().tween_property(slash_b, "modulate:a", 0.7, 0.025)
			active_tween.parallel().tween_property(slash_b, "scale:x", 1.0, 0.11)
		"FAYGO BREAK":
			slash_a.rotation = 1.16
			slash_b.rotation = 1.32
			active_tween.tween_property(slash_a, "modulate:a", 0.72, 0.03)
			active_tween.parallel().tween_property(slash_a, "scale:x", 0.78, 0.12)
			active_tween.parallel().tween_property(slash_b, "modulate:a", 0.82, 0.03)
			active_tween.parallel().tween_property(slash_b, "scale:x", 0.62, 0.12)
		"CARNIVAL SIGHT":
			flash.color = Color(tint.r, tint.g, tint.b, 1)
			active_tween.tween_property(flash, "modulate:a", 0.5, 0.055)
			active_tween.tween_property(flash, "modulate:a", 0.08, 0.08)
			active_tween.tween_property(flash, "modulate:a", 0.42, 0.055)
		"BACK DOOR":
			slash_a.rotation = 1.5708
			slash_b.rotation = 1.5708
			active_tween.tween_property(slash_a, "modulate:a", 0.88, 0.025)
			active_tween.parallel().tween_property(slash_a, "scale:x", 0.42, 0.13)
			active_tween.parallel().tween_property(slash_b, "modulate:a", 0.55, 0.025)
			active_tween.parallel().tween_property(slash_b, "scale:x", 0.24, 0.14)

	active_tween.tween_property(caption, "modulate:a", 1.0, 0.035)
	active_tween.parallel().tween_property(caption, "scale", Vector2(1.08, 1.08), 0.055)
	active_tween.parallel().tween_property(flash, "modulate:a", 0.42, 0.035)
	active_tween.tween_interval(0.07)
	active_tween.tween_property(caption, "modulate:a", 0.0, 0.2)
	active_tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.2)
	active_tween.parallel().tween_property(slash_a, "modulate:a", 0.0, 0.18)
	active_tween.parallel().tween_property(slash_b, "modulate:a", 0.0, 0.18)

func _stop_active() -> void:
	if active_tween and active_tween.is_running():
		active_tween.kill()

func _reset_layers() -> void:
	flash.modulate.a = 0.0
	caption.modulate.a = 0.0
	caption.scale = Vector2.ONE
	slash_a.modulate.a = 0.0
	slash_b.modulate.a = 0.0
	slash_a.scale = Vector2.ONE
	slash_b.scale = Vector2.ONE
	slash_a.rotation = -0.22
	slash_b.rotation = 0.18
