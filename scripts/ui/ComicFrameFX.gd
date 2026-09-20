extends PanelContainer

@export var sway_degrees := 0.22
@export var sway_seconds := 4.8
@export var art_drift_pixels := 7.0

@onready var art_stage: PanelContainer = $Margin/Layout/ArtStage
@onready var silhouette: TextureRect = $Margin/Layout/ArtStage/Silhouette
@onready var eyebrow: Label = $Margin/Layout/ArtStage/ArtStack/Eyebrow

var ambient_tween: Tween
var art_origin := Vector2.ZERO

func _ready() -> void:
	art_origin = silhouette.position
	pivot_offset = size * 0.5
	resized.connect(_refresh_pivot)
	_start_ambient_motion()

func _refresh_pivot() -> void:
	pivot_offset = size * 0.5

func _start_ambient_motion() -> void:
	if ambient_tween and ambient_tween.is_running():
		ambient_tween.kill()
	ambient_tween = create_tween().set_loops()
	ambient_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ambient_tween.tween_property(silhouette, "position:x", art_origin.x + art_drift_pixels, sway_seconds)
	ambient_tween.parallel().tween_property(eyebrow, "modulate:a", 0.62, sway_seconds)
	ambient_tween.tween_property(silhouette, "position:x", art_origin.x - art_drift_pixels, sway_seconds)
	ambient_tween.parallel().tween_property(eyebrow, "modulate:a", 1.0, sway_seconds)

func scene_hit(strength := 1.0) -> void:
	var amount: float = clampf(strength, 0.25, 1.5)
	rotation = deg_to_rad(-sway_degrees * amount * 5.0)
	scale = Vector2(1.0 - 0.018 * amount, 1.0 + 0.022 * amount)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", 0.0, 0.2)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.2)
