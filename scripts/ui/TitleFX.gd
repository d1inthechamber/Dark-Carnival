extends HBoxContainer

@onready var title: Label = $Title
@onready var badge: PanelContainer = $BrandBadge
@onready var build_tag: Label = $BuildTag

var motion: Tween

func _ready() -> void:
	call_deferred("_start_loop")

func _start_loop() -> void:
	if motion and motion.is_running():
		motion.kill()
	motion = create_tween().set_loops()
	motion.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	motion.tween_property(title, "position:y", title.position.y - 1.5, 1.65)
	motion.parallel().tween_property(build_tag, "modulate:a", 0.72, 1.65)
	motion.parallel().tween_property(badge, "rotation", deg_to_rad(-0.8), 1.65)
	motion.tween_property(title, "position:y", title.position.y + 1.5, 1.75)
	motion.parallel().tween_property(build_tag, "modulate:a", 1.0, 1.75)
	motion.parallel().tween_property(badge, "rotation", deg_to_rad(0.8), 1.75)
