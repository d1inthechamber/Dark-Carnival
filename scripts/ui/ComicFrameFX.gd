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
	silhouette.modulate = Color.WHITE
	art_stage.rotation = 0.0
	art_stage.scale = Vector2.ONE
	var drift := art_drift_pixels
	var seconds := sway_seconds
	match scene_mode:
		"mirrors":
			drift = art_drift_pixels * 2.0
			seconds = sway_seconds * 0.42
		"midway":
			drift = art_drift_pixels * 1.45
			seconds = sway_seconds * 0.64
		"gate":
			drift = art_drift_pixels * 0.7
			seconds = sway_seconds * 1.1
		"finale":
			drift = art_drift_pixels * 0.45
			seconds = sway_seconds * 1.45
	ambient_tween = create_tween().set_loops()
	ambient_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ambient_tween.tween_property(silhouette, "position:x", art_origin.x + drift, seconds)
	ambient_tween.parallel().tween_property(eyebrow, "modulate:a", 0.56, seconds)
	match scene_mode:
		"mirrors":
			ambient_tween.parallel().tween_property(silhouette, "scale", Vector2(1.045, 0.975), seconds)
			ambient_tween.parallel().tween_property(silhouette, "rotation", deg_to_rad(0.48), seconds)
			ambient_tween.parallel().tween_property(art_stage, "rotation", deg_to_rad(-0.16), seconds)
			ambient_tween.parallel().tween_property(silhouette, "modulate", Color(0.82, 1.0, 0.98, 0.86), seconds)
		"midway":
			ambient_tween.parallel().tween_property(silhouette, "position:y", art_origin.y - 4.0, seconds)
			ambient_tween.parallel().tween_property(art_stage, "scale", Vector2(1.009, 1.009), seconds)
		"gate":
			ambient_tween.parallel().tween_property(silhouette, "scale", Vector2(1.01, 1.018), seconds)
		"finale":
			ambient_tween.parallel().tween_property(silhouette, "modulate:a", 0.76, seconds)
			ambient_tween.parallel().tween_property(art_stage, "scale", Vector2(1.006, 1.006), seconds)
	ambient_tween.tween_property(silhouette, "position:x", art_origin.x - drift, seconds)
	ambient_tween.parallel().tween_property(eyebrow, "modulate:a", 1.0, seconds)
	match scene_mode:
		"mirrors":
			ambient_tween.parallel().tween_property(silhouette, "scale", Vector2(0.958, 1.026), seconds)
			ambient_tween.parallel().tween_property(silhouette, "rotation", deg_to_rad(-0.48), seconds)
			ambient_tween.parallel().tween_property(art_stage, "rotation", deg_to_rad(0.16), seconds)
			ambient_tween.parallel().tween_property(silhouette, "modulate", Color(1.0, 0.84, 0.96, 0.72), seconds)
		"midway":
			ambient_tween.parallel().tween_property(silhouette, "position:y", art_origin.y + 4.0, seconds)
			ambient_tween.parallel().tween_property(art_stage, "scale", Vector2.ONE, seconds)
		"gate":
			ambient_tween.parallel().tween_property(silhouette, "scale", Vector2(0.994, 0.988), seconds)
		"finale":
			ambient_tween.parallel().tween_property(silhouette, "modulate:a", 0.58, seconds)
			ambient_tween.parallel().tween_property(art_stage, "scale", Vector2(0.996, 0.996), seconds)

func scene_hit(strength := 1.0) -> void:
	var amount: float = clampf(strength, 0.25, 1.5)
	rotation = deg_to_rad(-sway_degrees * amount * 5.0)
	scale = Vector2(1.0 - 0.018 * amount, 1.0 + 0.022 * amount)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", 0.0, 0.2)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.2)

func mirror_glitch() -> void:
	if scene_mode != "mirrors": return
	var base := silhouette.position
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(silhouette, "position", base + Vector2(18, -5), 0.035)
	tween.parallel().tween_property(silhouette, "scale", Vector2(1.08, 0.93), 0.035)
	tween.tween_property(silhouette, "position", base + Vector2(-14, 4), 0.045)
	tween.parallel().tween_property(silhouette, "scale", Vector2(0.94, 1.06), 0.045)
	tween.tween_property(silhouette, "position", base, 0.08)
	tween.parallel().tween_property(silhouette, "scale", Vector2.ONE, 0.08)
