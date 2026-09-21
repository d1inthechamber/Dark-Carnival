extends PanelContainer

@export var sway_degrees := 0.22
@export var sway_seconds := 4.8
@export var art_drift_pixels := 7.0

@onready var art_stage: PanelContainer = $Margin/Layout/ArtStage
@onready var silhouette: TextureRect = $Margin/Layout/ArtStage/Silhouette
@onready var eyebrow: Label = $Margin/Layout/ArtStage/ArtStack/Eyebrow

var ambient_tween: Tween
var art_origin := Vector2.ZERO
var scene_mode := "opening"

func _ready() -> void:
	art_origin = silhouette.position
	pivot_offset = size * 0.5
	resized.connect(_refresh_pivot)
	_start_ambient_motion()

func _refresh_pivot() -> void:
	pivot_offset = size * 0.5

func set_scene_mode(mode:String) -> void:
	scene_mode = mode
	_start_ambient_motion()

func _start_ambient_motion() -> void:
	if ambient_tween and ambient_tween.is_running():
		ambient_tween.kill()
	silhouette.position = art_origin
	silhouette.rotation = 0.0
	silhouette.scale = Vector2.ONE
	art_stage.rotation = 0.0
	art_stage.scale = Vector2.ONE
	var drift := art_drift_pixels
	var seconds := sway_seconds
	match scene_mode:
		"mirrors":
			drift = art_drift_pixels * 1.8
			seconds = sway_seconds * 0.5
		"midway":
			drift = art_drift_pixels * 1.3
			seconds = sway_seconds * 0.7
		"gate":
			drift = art_drift_pixels * 0.65
			seconds = sway_seconds * 1.15
		"finale":
			drift = art_drift_pixels * 0.5
			seconds = sway_seconds * 1.35
	ambient_tween = create_tween().set_loops()
	ambient_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ambient_tween.tween_property(silhouette, "position:x", art_origin.x + drift, seconds)
	ambient_tween.parallel().tween_property(eyebrow, "modulate:a", 0.58, seconds)
	match scene_mode:
		"mirrors":
			ambient_tween.parallel().tween_property(silhouette, "scale", Vector2(1.025, 0.992), seconds)
			ambient_tween.parallel().tween_property(silhouette, "rotation", deg_to_rad(0.28), seconds)
			ambient_tween.parallel().tween_property(art_stage, "rotation", deg_to_rad(-0.08), seconds)
		"midway":
			ambient_tween.parallel().tween_property(silhouette, "position:y", art_origin.y - 3.0, seconds)
			ambient_tween.parallel().tween_property(art_stage, "scale", Vector2(1.006, 1.006), seconds)
		"gate":
			ambient_tween.parallel().tween_property(silhouette, "scale", Vector2(1.008, 1.015), seconds)
		"finale":
			ambient_tween.parallel().tween_property(silhouette, "modulate:a", 0.82, seconds)
	ambient_tween.tween_property(silhouette, "position:x", art_origin.x - drift, seconds)
	ambient_tween.parallel().tween_property(eyebrow, "modulate:a", 1.0, seconds)
	match scene_mode:
		"mirrors":
			ambient_tween.parallel().tween_property(silhouette, "scale", Vector2(0.978, 1.008), seconds)
			ambient_tween.parallel().tween_property(silhouette, "rotation", deg_to_rad(-0.28), seconds)
			ambient_tween.parallel().tween_property(art_stage, "rotation", deg_to_rad(0.08), seconds)
		"midway":
			ambient_tween.parallel().tween_property(silhouette, "position:y", art_origin.y + 3.0, seconds)
			ambient_tween.parallel().tween_property(art_stage, "scale", Vector2.ONE, seconds)
		"gate":
			ambient_tween.parallel().tween_property(silhouette, "scale", Vector2(0.995, 0.99), seconds)
		"finale":
			ambient_tween.parallel().tween_property(silhouette, "modulate:a", 0.64, seconds)

func scene_hit(strength := 1.0) -> void:
	var amount: float = clampf(strength, 0.25, 1.5)
	rotation = deg_to_rad(-sway_degrees * amount * 5.0)
	scale = Vector2(1.0 - 0.018 * amount, 1.0 + 0.022 * amount)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", 0.0, 0.2)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.2)
