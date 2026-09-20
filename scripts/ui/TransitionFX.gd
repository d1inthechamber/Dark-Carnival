extends Control

@onready var flash: ColorRect = $Flash
@onready var caption: Label = $Caption

var active_tween: Tween

func impact(text: String = "", tint: Color = Color(0.95, 0.08, 0.22, 1.0)) -> void:
	if active_tween and active_tween.is_running():
		active_tween.kill()

	flash.color = tint
	flash.modulate.a = 0.0
	caption.text = text
	caption.modulate.a = 0.0

	active_tween = create_tween()
	active_tween.tween_property(flash, "modulate:a", 0.72, 0.04)
	active_tween.parallel().tween_property(caption, "modulate:a", 1.0, 0.04)
	active_tween.tween_interval(0.08)
	active_tween.tween_property(flash, "modulate:a", 0.0, 0.24)
	active_tween.parallel().tween_property(caption, "modulate:a", 0.0, 0.24)
